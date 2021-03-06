% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotSequenceQualitiesHeatmap.R
\name{plotSequenceQualitiesHeatmap}
\alias{plotSequenceQualitiesHeatmap}
\title{Plot the Per Sequence Quality Scores}
\usage{
plotSequenceQualitiesHeatmap(x, subset, counts = FALSE, pwfCols,
  trimNames = TRUE, pattern = "(.+)\\\\.(fastq|fq).*", usePlotly = FALSE,
  clusterNames = FALSE)
}
\arguments{
\item{x}{Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
\code{FastqcDataList} or path}

\item{subset}{\code{logical}. Return the values for a subset of files.
May be useful to only return totals from R1 files, or any other subset}

\item{counts}{\code{logical}. Plot the counts from each file if \code{counts = TRUE}.
If \code{counts = FALSE} the frequencies will be plotted}

\item{pwfCols}{Object of class \code{\link{PwfCols}} containing the colours for PASS/WARN/FAIL}

\item{trimNames}{\code{logical}. Capture the text specified in \code{pattern} from fileName}

\item{pattern}{\code{character}.
Contains a regular expression which will be captured from fileName.
The default will capture all text preceding .fastq/fastq.gz/fq/fq.gz}

\item{usePlotly}{\code{logical} Default \code{FALSE} will render using ggplot.
If \code{TRUE} plot will be rendered with plotlyz}

\item{clusterNames}{\code{logical} default \code{FALSE}. If set to \code{TRUE},
fastqc data will be clustered using heirachial clustering}
}
\value{
A ggplot2 object
}
\description{
Plot the Per Sequence Quality Scores for a set of FASTQC reports
}
\details{
Plots the distribution of average sequence quality scores across the set of files.
Values can be plotted either as counts (\code{counts = TRUE}) or as frequencies (\code{counts = FALSE}).

Any faceting or scale adjustment can be performed after generation of the initial plot,
using the standard methods of ggplot2 as desired.
}
