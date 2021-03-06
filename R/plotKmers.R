#' @title Plot Overrepresented Kmers
#'
#' @description Plot Overrepresented Kmers across an entire library
#'
#' @details This plots the top overrepresented Kmers for one or more FASTQC reports.
#' Sequences are coloured in order of first appearance from left to right for easy
#' identification of larger sequences.
#'
#' Returned plots can be easily modified using the standard ggplot2 methods
#'
#' @param x Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
#' \code{FastqcDataList} or path
#' @param subset \code{logical}. Return the values for a subset of files.
#' May be useful to only return totals from R1 files, or any other subset
#' @param nc \code{numeric}. The number of columns to create in the plot layout
#' @param nKmers \code{numeric}. The number of Kmers to show.
#' @param method Can only take the values \code{"overall"} or \code{"individual"}.
#' Determines whether the top nKmers are selected by the overall ranking (based on Obs/Exp_Max),
#' or whether the top nKmers are selected from each individual file.
#' @param trimNames \code{logical}. Capture the text specified in \code{pattern} from fileName
#' @param pattern \code{character}.
#' Contains a regular expression which will be captured from fileName.
#' The default will capture all text preceding .fastq/fastq.gz/fq/fq.gz
#' @param usePlotly \code{logical} Default \code{FALSE} will render using ggplot.
#' If \code{TRUE} plot will be rendered with plotly
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
#' # Not a great example
#' plotKmers(fdl)
#'
#' # Try digging a bit deeper
#' ccR1 <- grepl("CC.+R1", fileName(fdl))
#' plotKmers(fdl, subset = ccR1, nc = 1, method = "individual", nKmers = 4)
#'
#'
#' @importFrom stringr str_detect
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr slice
#' @importFrom dplyr data_frame
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr arrange
#' @importFrom dplyr rename
#' @importFrom plotly ggplotly
#'
#'
#'
#' @export
plotKmers <- function(x, subset, nc = 2, nKmers = 6, method = "overall",
                      trimNames = TRUE, pattern = "(.+)\\.(fastq|fq).*",
                      usePlotly = FALSE){

  # A basic cautionary check
  stopifnot(grepl("(Fastqc|character)", class(x)))

  if (missing(subset)){
    subset <- rep(TRUE, length(x))
  }
  stopifnot(is.logical(subset))
  stopifnot(length(subset) == length(x))
  stopifnot(is.logical(trimNames))
  stopifnot(is.numeric(nc))
  stopifnot(is.numeric(nKmers))
  stopifnot(method %in% c("overall", "individual"))

  x <- x[subset]
  df <- tryCatch(Kmer_Content(x))

  # Check the pattern contains a capture
  if (trimNames && stringr::str_detect(pattern, "\\(.+\\)")) {
    df$Filename <- gsub(pattern[1], "\\1", df$Filename)
    # These need to be checked to ensure non-duplicated names
    if (length(unique(df$Filename)) != length(x)) stop("The supplied pattern will result in duplicated filenames, which will not display correctly.")
  }

  # Get the top kMers from each file, or from the overall list
  nKmers <- as.integer(nKmers)
  if (method == "individual"){
    topKmers <- df %>%
      split(f = .$Filename) %>%
      lapply(dplyr::arrange, desc(`Obs/Exp_Max`)) %>%
      lapply(dplyr::slice, 1:nKmers) %>%
      dplyr::bind_rows() %>%
      magrittr::extract2("Sequence") %>%
      unique()
  }
  if (method == "overall"){
    topKmers <- df %>%
      dplyr::arrange(desc(`Obs/Exp_Max`)) %>%
      dplyr::distinct(Sequence) %>%
      dplyr::slice(1:nKmers) %>%
      magrittr::extract2("Sequence")
  }

  df <- dplyr::filter(df, Sequence %in% topKmers) %>%
    dplyr::rename(Base = `Max_Obs/Exp_Position`) %>%
    dplyr::mutate(Start = gsub("([0-9]*)-[0-9]*", "\\1", Base),
                  Start = as.integer(Start)) %>%
    dplyr::select(Filename, Sequence, `Obs/Exp_Max`, Start)   # The PValue and Count columns are ignored for this plot

  # Set the x-axis for plotting
  # As there will be significant gaps in this data,
  # the bins used need to be obtained from another slot.
  # The most complete will be Per_base_sequence_quality
  # These values can then be incorporated in the final df for accurate plotting & labelling
  refForX <- unique(Per_base_sequence_quality(x)$Base)
  refForX <- dplyr::data_frame(Base = as.character(refForX),
                               Start = gsub("([0-9]*)-[0-9]*", "\\1", Base))
  refForX$Start <- as.integer(refForX$Start)

  # In order to get a line plot, zero values need to be added to the missing positions
  # The above reference scale for X will be used to label the missing values
  # Include all files to ensure all appear in the final plot
  if (trimNames) allNames <- gsub(pattern[1], "\\1", fileName(x))
  zeros <- with(df,
                expand.grid(list(Filename = allNames,
                                 Sequence = unique(Sequence),
                                 `Obs/Exp_Max` = 0,
                                 Start = seq(0, max(Start) + 0.5, by = 0.5)),
                            stringsAsFactors = FALSE))

  # After the bind_rows, duplicate values will exist at some positions
  # Spuriously introduced zeros need to be removed
  df <- dplyr::bind_rows(df, zeros) %>%
    dplyr::arrange(Filename, Sequence, Start, desc(`Obs/Exp_Max`)) %>%
    dplyr::distinct(Filename, Sequence, Start, .keep_all = TRUE)

  # Set the Sequence as a factor based on the first position it appears
  # This way the colours will appear in order in the guide as well as the plot
  kMerLevels <- df %>%
    dplyr::filter(`Obs/Exp_Max` != 0) %>%
    dplyr::arrange(Start) %>%
    dplyr::distinct(Sequence) %>%
    magrittr::extract2("Sequence")
  df$Sequence <- factor(df$Sequence, levels = kMerLevels)

  # Now draw the basic plots
  kMerPlot <- ggplot(df,
                              aes(x = Start, y = `Obs/Exp_Max`, colour = Sequence)) +
    geom_line() +
    facet_wrap(~Filename, ncol = nc) +
    scale_x_continuous(breaks = refForX$Start,
                                labels = refForX$Base) +
    theme_bw() +
    ylab(expression(paste(log[2], " Obs/Exp"))) +
    xlab("Position in read (bp)")

  # Check for binned x-axis values to decied whether to rotate x-axis labels
  # This should be clear if there are more than 2 characters in the plotted labels
  binned <- max(nchar(dplyr::filter(refForX, Start %in% df$Start)$Base)) > 2
  if (binned) {
    kMerPlot <- kMerPlot +
      theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
  }

  if(usePlotly){
    kMerPlot <- ggplotly(kMerPlot)
  }

  # Draw the plot
  kMerPlot

}
