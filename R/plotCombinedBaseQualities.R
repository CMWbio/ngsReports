#' @title Plot the combined Per_base_sequence_quality information
#'
#' @description Plot the Per_base_sequence_quality information for a set of FASTQC reports
#'
#' @details This enables plotting of any of the supplied values (i.e. Mean, Median etc) across
#' a set of FASTQC reports.
#' By default only the Mean will be plotted,
#' however any number of the supplied values can be added to the plot,
#' and these will be separated by linetype.
#'
#' @param x Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
#' \code{FastqcDataList} or path
#' @param subset \code{logical}. Return the values for a subset of files.
#' May be useful to only return totals from R1 files, or any other subset
#' @param value \code{character}. Specify which value whould be plotted.
#' Can be any of the columns returned by \code{Per_base_sequence_quality}.
#' Defaults to \code{value = "Mean"}.
#' Can additionally set to "all" to plot all available quantities
#' @param pwfCols Object of class \code{PwfCols} containing the colours for PASS/WARN/FAIL.
#' Defaults to the object \code{pwf}
#' @param trimNames \code{logical}. Capture the text specified in \code{pattern} from fileName
#' @param pattern \code{character}.
#' Contains a regular expression which will be captured from fileName.
#' The default will capture all text preceding .fastq/fastq.gz/fq/fq.gz
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
#' # Find the R1 files
#' r1 <- grepl("R1", fileName(fdl))
#'
#' # The default plot using the Mean only
#' plotCombinedBaseQualities(fdl)
#'
#' # Plot the R1 files showing the Mean and Lower_Quartile
#' plotCombinedBaseQualities(fdl, subset = r1, value = c("Mean", "Lower_Quartile"))
#'
#'
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 annotate
#' @importFrom ggplot2 geom_line
#' @importFrom ggplot2 scale_x_continuous
#' @importFrom ggplot2 scale_y_continuous
#' @importFrom ggplot2 ylab
#' @importFrom ggplot2 theme_bw
#'
#' @export
plotCombinedBaseQualities <- function(x, subset, value = "Mean", pwfCols,
                                      trimNames = TRUE, pattern = "(.+)\\.(fastq|fq).*"){

  # A basic cautionary check
  stopifnot(grepl("(Fastqc|character)", class(x)))

  # Sort out the colours
  if (missing(pwfCols)) pwfCols <- ngsReports::pwf
  stopifnot(isValidPwf(pwfCols))

  if (missing(subset)){
    subset <- rep(TRUE, length(x))
  }
  stopifnot(is.logical(trimNames))
  stopifnot(is.character(value))

  x <- tryCatch(x[subset])
  df <- tryCatch(Per_base_sequence_quality(x))

  # Check for valid columns
  value <- setdiff(value, c("Filename", "Base")) # Not relevant columns
  if (length(value) == 0) {
    message("Invalid column specified, setting as 'Mean' (default)")
    value <- "Mean"
  }
  # Any vector containing 'all' will return all values...
  if (!any(grepl("all", value))){
    value <- intersect(value, colnames(df)[-c(1:2)])
    if (length(value) == 0) stop("The specified value could not be found in the output from Per_base_sequence_quality")
  }

  # Check the pattern contains a capture
  if (trimNames && stringr::str_detect(pattern, "\\(.+\\)")) {
    df$Filename <- gsub(pattern[1], "\\1", df$Filename)
    # These need to be checked to ensure non-duplicated names
    if (length(unique(df$Filename)) != length(x)) stop("The supplied pattern will result in duplicated filenames, which will not display correctly.")
  }

  # Get the Illumina encoding
  enc <-  Basic_Statistics(x)$Encoding[1]
  enc <- gsub(".*(Illumina [0-9\\.]*)", "\\1", enc)

  # Find the central position for each base as some may be grouped
  df <- dplyr::mutate(df,
                      Start = gsub("([0-9]*)-[0-9]*", "\\1", Base),
                      Start = as.integer(Start),
                      End = gsub("[0-9]*-([0-9]*)", "\\1", Base),
                      End = as.integer(End),
                      Base = 0.5*(Start + End))
  df <- dplyr::select(df, -Start, -End)
  if (!any(grepl("all", value))) df <- dplyr::select(df, Filename, Base, dplyr::one_of(value))
  df <- reshape2::melt(df, id.vars = c("Filename", "Base"),
                       variable.name = "Value", value.name = "Score")

  # Make basic plot, adding the shaded background colours
  qualPlot <- ggplot(df, aes(x = Base, y = Score, colour = Filename)) +
    annotate("rect", xmin = 0, xmax = Inf, ymin = 30, ymax = Inf,
                      fill = getColours(pwfCols)["PASS"], alpha = 0.3) +
    annotate("rect", xmin = 0, xmax = Inf, ymin = 20, ymax = 30,
                      fill = getColours(pwfCols)["WARN"], alpha = 0.3) +
    annotate("rect", xmin = 0, xmax = Inf, ymin = -Inf, ymax = 20,
                      fill = getColours(pwfCols)["FAIL"], alpha = 0.3) +
    geom_line(aes(linetype = Value)) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    ylab(paste0("Quality Scores (", enc, " encoding)")) +
    theme_bw()

  # Draw the plot
  qualPlot

}
