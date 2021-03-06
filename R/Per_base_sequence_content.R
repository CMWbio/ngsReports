#' @title Get the Per Base Sequence Content information
#'
#' @description Retrieve the Per Base Sequence Content module from one or more FastQC reports
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
#'
#' @export
#' @rdname Per_base_sequence_content
#' @aliases Per_base_sequence_content
setMethod("Per_base_sequence_content", "FastqcData",
          function(object){
            df <- object@Per_base_sequence_content
            df$Filename <- fileName(object)
            dplyr::select(df, Filename, dplyr::everything())
          })

#' @export
#' @rdname Per_base_sequence_content
#' @aliases Per_base_sequence_content
setMethod("Per_base_sequence_content", "FastqcDataList",
          function(object){
            df <- lapply(object@.Data, Per_base_sequence_content)
            dplyr::bind_rows(df)
          })

#' @export
#' @rdname Per_base_sequence_content
#' @aliases Per_base_sequence_content
setMethod("Per_base_sequence_content", "FastqcFile",
          function(object){
            object <- getFastqcData(object)
            Per_base_sequence_content(object)
          })

#' @export
#' @rdname Per_base_sequence_content
#' @aliases Per_base_sequence_content
setMethod("Per_base_sequence_content", "FastqcFileList",
          function(object){
            object <- getFastqcData(object)
            Per_base_sequence_content(object)
          })

#' @export
#' @rdname Per_base_sequence_content
#' @aliases Per_base_sequence_content
setMethod("Per_base_sequence_content", "character",
          function(object){
            object <- getFastqcData(object)
            Per_base_sequence_content(object)
          })
