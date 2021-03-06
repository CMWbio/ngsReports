#' @title Draw a barplot of read totals
#'
#' @description Draw a barplot of read totals
#'
#' @details Draw a barplot of read totals using the standard ggplot2 syntax.
#' Read totals will be plotted in millions as this is the most common.
#' The raw data from \code{\link{readTotals}} can otherwise be used to manually create a plot.
#'
#' @param x Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
#' \code{FastqcDataList} or path
#' @param subset \code{logical}. Return the values for a subset of files.
#' May be useful to only return totals from R1 files, or any other subset
#' @param millions \code{logical}. Use Millions of reads as the scale for the y-axis.
#' Unless specified, will be set as TRUE automatically if the highest total is > 2e06.
#' @param trimNames \code{logical}. Capture the text specified in \code{pattern} from fileName
#' @param pattern \code{character}.
#' Contains a regular expression which will be captured from fileName.
#' The default will capture all text preceding .fastq/fastq.gz/fq/fq.gz
#' @param usePlotly \code{logical} Default \code{FALSE} will render using ggplot.
#' If \code{TRUE} plot will be rendered with plotly
#'
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
#' # Plot the Read Totals
#' plotReadTotals(fdl)
#'
#' # Change the scale so it is not in millions
#' # Also subset the reads to just the R1 files
#' r1 <- grepl("R1", fileName(fdl))
#' plotReadTotals(fdl, subset = r1, millions = FALSE)
#'
#' @return Returns a ggplot object.
#'
#'
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 geom_bar
#' @importFrom ggplot2 theme_bw
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 element_text
#' @importFrom plotly ggplotly
#'
#' @export
plotReadTotals <- function(x, subset, millions,
                           trimNames = TRUE, pattern = "(.+)\\.(fastq|fq).*",
                           usePlotly = FALSE){

  stopifnot(grepl("(Fastqc|character)", class(x)))

  if (missing(subset)){
    subset <- rep(TRUE, length(x))
  }
  stopifnot(is.logical(subset))
  stopifnot(length(subset) == length(x))
  stopifnot(is.logical(trimNames))

  df <- readTotals(x, subset = subset, trimNames = trimNames, pattern = pattern)

  # Automatically determine whether to convert to millions
  if (missing(millions)) {
    millions <- ifelse(max(df$Total_Sequences) > 2e06, TRUE, FALSE)
  }
  stopifnot(is.logical(millions))

  # Setup the basic plot in millions or not
  if (millions){
    rtPlot <- ggplot(df, aes(x = Filename, y = Total_Sequences/1e06)) +
      labs(y = "Total Reads (millions)")
  }
  else{
    rtPlot <- ggplot(df, aes(x = Filename, y = Total_Sequences)) +
      labs(y = "Total Reads")
  }

  # Add the rest of the parameters
  rtPlot <- rtPlot +
    geom_bar(stat = "identity") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

  if(usePlotly){
    rtPlot <- ggplotly(rtPlot)
  }
  # Draw the plot
  rtPlot

}
