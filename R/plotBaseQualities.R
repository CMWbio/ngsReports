#' @title Plot the Base Qualities for each file
#'
#' @description Plot the Base Qualities for each file as separate plots
#'
#' @details This replicates the \code{Per base sequence quality} plots from FASTQC,
#' using facets to plce them all in a single ggplot2 object.
#'
#' For large datasets, subsetting by R1 or R2 reads may be helpful
#'
#' @param x Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
#' \code{FastqcDataList} or path
#' @param subset \code{logical}. Return the values for a subset of files.
#' May be useful to only return totals from R1 files, or any other subset
#' @param nc \code{numeric}. The number of columns to create in the plot layout
#' @param pwfCols Object of class \code{\link{PwfCols}} containing the colours for PASS/WARN/FAIL
#' @param trimNames \code{logical}. Capture the text specified in \code{pattern} from fileName
#' @param pattern \code{character}.
#' Contains a regular expression which will be captured from fileName.
#' The default will capture all text preceding .fastq/fastq.gz/fq/fq.gz
#' @param usePlotly \code{logical} Default \code{FALSE} will render using ggplot.
#' If \code{TRUE} plot will be rendered with plotly
#'
#'
#' @return A standard ggplot2 object
#'
#' @examples
#'
#' # Get the files included with the package
#' barcodes <- c("ATTG", "CCGC", "CCGT", "GACC", "TTAT", "TTGG")
#' suffix <- c("R1_fastqc.zip", "R2_fastqc.zip")
#' fileList <- paste(rep(barcodes, each = 2), rep(suffix, times = 5), sep = "_")
#' fileList <- system.file("extdata", fileList, package = "ngsReports")
#'
#' # Load the FASTQC data as a FastqcDataList
#' fdl <- getFastqcData(fileList)
#'
#' # The default and subset plot
#' plotBaseQualities(fdl)
#'
#' # Plot the R1 files using counts
#' r1 <- grepl("R1", fileName(fdl))
#' plotBaseQualities(fdl, subset = r1)
#'
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 annotate
#' @importFrom ggplot2 geom_crossbar
#' @importFrom ggplot2 geom_segment
#' @importFrom ggplot2 geom_linerange
#' @importFrom ggplot2 geom_line
#' @importFrom ggplot2 scale_x_continuous
#' @importFrom ggplot2 scale_y_continuous
#' @importFrom ggplot2 xlab
#' @importFrom ggplot2 ylab
#' @importFrom ggplot2 facet_wrap
#' @importFrom ggplot2 theme_bw
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 element_blank
#' @importFrom ggplot2 element_text
#' @importFrom plotly ggplotly
#'
#' @export
plotBaseQualities <- function(x, subset, nc = 2, pwfCols,
                              trimNames = TRUE, pattern = "(.+)\\.(fastq|fq).*",
                              usePlotly = FALSE){

  # A basic cautionary check
  stopifnot(grepl("(Fastqc|character)", class(x)))
  stopifnot(is.logical(trimNames))

  # Sort out the colours
  if (missing(pwfCols)) pwfCols <- ngsReports::pwf
  stopifnot(isValidPwf(pwfCols))
  cols <- getColours(pwfCols)


  if (missing(subset)){
    subset <- rep(TRUE, length(x))
  }
  x <- tryCatch(x[subset])

  df <- tryCatch(Per_base_sequence_quality(x))
  df <- dplyr::mutate(df,
                      Start = gsub("([0-9]*)-[0-9]*", "\\1", Base),
                      Start = as.integer(Start),
                      Start = as.factor(Start))

  # Check the pattern contains a capture
  if (trimNames && stringr::str_detect(pattern, "\\(.+\\)")) {
    df$Filename <- gsub(pattern[1], "\\1", df$Filename)
    # These need to be checked to ensure non-duplicated names
    if (length(unique(df$Filename)) != length(x)) stop("The supplied pattern will result in duplicated filenames, which will not display correctly.")
  }

  # Set the y limit
  ylim <- c(0, max(df$`90th_Percentile`) + 1)

  # Get the Illumina encoding
  enc <- Basic_Statistics(x)$Encoding[1]
  enc <- gsub(".*(Illumina [0-9\\.]*)", "\\1", enc)

  qualPlot <- ggplot(df, aes(x = as.integer(Start), y = Median)) +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 30, ymax = Inf,
                      fill = getColours(pwfCols)["PASS"], alpha = 0.3) +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 20, ymax = 30,
                      fill = getColours(pwfCols)["WARN"], alpha = 0.3) +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 20,
                      fill = getColours(pwfCols)["FAIL"], alpha = 0.3) +
    geom_crossbar(aes(ymin = Lower_Quartile, ymax = Upper_Quartile),
                           fill = "yellow", width = 0.8, size = 0.2) +
    geom_segment(aes(x = as.integer(Start)-0.4, xend = as.integer(Start) + 0.4,
                                       yend = Median), colour = "red") +
    geom_linerange(aes(ymin = `10th_Percentile`, ymax = Lower_Quartile)) +
    geom_linerange(aes(ymin = Upper_Quartile, ymax = `90th_Percentile`)) +
    geom_line(aes(y = Mean), colour = "blue") +
    scale_x_continuous(breaks = seq_along(levels(df$Start)),
                                labels = unique(df$Base),
                                expand = c(0, 0)) +
    scale_y_continuous(limits = ylim, expand = c(0,0)) +
    xlab("Position in read (bp)") +
    ylab(paste0("Quality Scores (", enc, " encoding)")) +
    facet_wrap(~Filename, ncol = nc) +
    theme_bw() +
    theme(panel.grid.minor = element_blank(),
                   axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

  if(usePlotly){
  cutOffs <- data.frame(pass = 30, Filename = df$Filename, warn = 20, fail = 0, top =  max(ylim))

  qualPlot <- ggplotly(qualPlot)# %>% add_trace(data = test, y = ~top, type = 'scatter', mode = 'lines',
    #                     line = list(color = NULL),
    #                     showlegend = FALSE, name = 'high 2014', xmin = 0, xmax = Inf, ymin = 20, ymax =  ylim, fillopacity = 0.1, hoverinfo = "none") %>%
    # add_trace(data = cutOffs, y = ~pass, type = 'scatter', mode = 'lines',
    #           fill = 'tonexty', fillcolor=adjustcolor(cols["PASS"], alpha.f = 0.1),
    #           line = list(color = adjustcolor(cols["PASS"], alpha.f = 0.1)),
    #           xmin = 0, xmax = Inf, ymin = 30, ymax = 40, hoverinfo = "none") %>%
    # add_trace(data = cutOffs, y = ~warn, type = 'scatter', mode = 'lines',
    #           fill = 'tonexty', fillcolor=adjustcolor(cols["WARN"], alpha.f = 0.1),
    #           line = list(color = adjustcolor(cols["WARN"], alpha.f = 0.1)),
    #           xmin = 0, xmax = Inf, ymin = -Inf, ymax = 0, hoverinfo = "none") %>%
    # add_trace(data = cutOffs, y = ~fail, type = 'scatter', mode = 'lines',
    #           fill = 'tonexty', fillcolor=adjustcolor(cols["FAIL"], alpha.f = 0.1),
    #           line = list(color = adjustcolor(cols["FAIL"], alpha.f = 0.1)),
    #           xmin = 0, xmax = Inf, ymin = -Inf, ymax = 0, hoverinfo = "none")
  }

  qualPlot
}

