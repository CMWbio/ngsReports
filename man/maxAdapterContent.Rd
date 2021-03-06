% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/maxAdapterContent.R
\name{maxAdapterContent}
\alias{maxAdapterContent}
\title{Get the maximum Adapter Content}
\usage{
maxAdapterContent(x, digits = 2, asPercent = TRUE)
}
\arguments{
\item{x}{Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData},
\code{FastqcDataList} or path}

\item{digits}{\code{numeric}.
The output will have the percentages rounded to the specified number of digits}

\item{asPercent}{\code{logical}.
Format the values as percentages with the added \code{\%} symbol}
}
\value{
A \code{data_frame} object containing the percent of reads with each adapter
type at the final position
}
\description{
Get the maximum Adapter Content across one or more FASTQC reports
}
\details{
This will extract the \code{Adapter_Content} from the supplied object,
and provide a \code{data_frame} with the final value for each file
}
