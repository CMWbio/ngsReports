% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotGcHeatmap.R
\name{plotGcHeatmap}
\alias{plotGcHeatmap}
\title{Plot the GC content as a heatmap}
\usage{
plotGcHeatmap(x, subset, counts = FALSE, trimNames = TRUE,
  pattern = "(.+)\\\\.(fastq|fq).*")
}
\arguments{
\item{x}{Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
\code{FastqcDataList} or path}

\item{subset}{\code{logical}. Return the values for a subset of files.
May be useful to only return totals from R1 files, or any other subset}

\item{counts}{\code{logical}. Plot the counts from each file if \code{counts = TRUE}.
If \code{counts = FALSE} the frequencies will be plotted}

\item{trimNames}{\code{logical}. Capture the text specified in \code{pattern} from fileName}

\item{pattern}{\code{character}.
Contains a regular expression which will be captured from fileName.
The default will capture all text preceding .fastq/fastq.gz/fq/fq.gz}
}
\value{
A ggplot2 object
}
\description{
Plot the Per Sequence GC Content for a set of FASTQC files
}
\examples{

# Get the files included with the package
barcodes <- c("ATTG", "CCGC", "CCGT", "GACC", "TTAT", "TTGG")
suffix <- c("R1_fastqc.zip", "R2_fastqc.zip")
fileList <- paste(rep(barcodes, each = 2), rep(suffix, times = 5), sep = "_")
fileList <- system.file("extdata", fileList, package = "ngsReports")

# Load the FASTQC data as a FastqcDataList
fdl <- getFastqcData(fileList)

# The default plot
plotGcHeatmap(fdl)

# Using counts
plotGcHeatmap(fdl, counts = TRUE)


}
