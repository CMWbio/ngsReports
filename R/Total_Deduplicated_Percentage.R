#' @title Get the Total Deduplicated Percentage information
#'
#' @description Retrieve the Total Deduplicated Percentage module from one or more FastQC reports
#'
#' @param object Can be a \code{FastqcFile}, \code{FastqcFileList}, \code{FastqcData}, \code{fastqcDataList},
#' or simply a \code{character} vector of paths to fastqc files
#'
#' @include AllClasses.R
#' @include AllGenerics.R
#'
#' @return A single \code{data_frame} containing all information combined from all supplied FastQC reports
#'
#' @docType methods
#'
#' @importFrom dplyr data_frame
#' @importFrom dplyr bind_rows
#'
#' @export
#' @rdname Total_Deduplicated_Percentage
#' @aliases Total_Deduplicated_Percentage
setMethod("Total_Deduplicated_Percentage", "FastqcData",
          function(object){
            dplyr::data_frame(Filename = fileName(object),
                              Total = object@Total_Deduplicated_Percentage)
          })

#' @export
#' @rdname Total_Deduplicated_Percentage
#' @aliases Total_Deduplicated_Percentage
setMethod("Total_Deduplicated_Percentage", "FastqcDataList",
          function(object){
            df <- lapply(object@.Data, Total_Deduplicated_Percentage)
            dplyr::bind_rows(df)
          })

#' @export
#' @rdname Total_Deduplicated_Percentage
#' @aliases Total_Deduplicated_Percentage
setMethod("Total_Deduplicated_Percentage", "FastqcFile",
          function(object){
            object <- getFastqcData(object)
            Total_Deduplicated_Percentage(object)
          })

#' @export
#' @rdname Total_Deduplicated_Percentage
#' @aliases Total_Deduplicated_Percentage
setMethod("Total_Deduplicated_Percentage", "FastqcFileList",
          function(object){
            object <- getFastqcData(object)
            Total_Deduplicated_Percentage(object)
          })

#' @export
#' @rdname Total_Deduplicated_Percentage
#' @aliases Total_Deduplicated_Percentage
setMethod("Total_Deduplicated_Percentage", "character",
          function(object){
            object <- getFastqcData(object)
            Total_Deduplicated_Percentage(object)
          })
