#' @title Import STAR log files
#'
#' @description Imports \code{Log.final.out} files generated by STAR
#'
#' @details Imports one or more \code{Log.final.out} files as output by the aligner STAR
#' Values which are simple to calculate from the returned information are returned
#' as proportions intead of percentages.
#' Indel and substitution rates are left as character values showing percentages.
#'
#' @param x \code{character}. Vector of filenames
#' @param tidyNames \code{logical}(1). Return names in slightly more convenient format (TRUE)
#' or mostly as provided on the original file
#'
#' @return A \code{data_frame}.
#' Column names are broadly similar to those in the supplied files,
#' but have been modified for easier handling under R naming conventions.
#'
#' In addition, the columns \code{Mapping_Duration} and the overall \code{Total_Mapped_Percent}
#' are returned
#'
#' @export
importStarLogs <- function(x, tidyNames = TRUE){

  stopifnot(file.exists(x))
  ln <- lapply(x, readLines)

  # Define a quick check
  isValidStarLog <- function(x){
    if (!grepl("Started job on", x[1])) return(FALSE)
    if (!any(grepl("UNIQUE READS:", x))) return(FALSE)
    if (!any(grepl("MULTI-MAPPING READS:", x))) return(FALSE)
    if (!any(grepl("UNMAPPED READS:", x))) return(FALSE)
    TRUE
  }
  validLogs <- vapply(ln, isValidStarLog, logical(1))
  if (any(!validLogs)) {
    stop(paste("Incorrect file structure for:", names(validLogs)[!validLogs], collapse = "\n"))
  }

  ln <- lapply(ln, stringr::str_split_fixed, pattern = "\\|\t", n = 2)
  ln <- lapply(ln, function(x){
    x <- x[x[,2] != "",] # Remove blanks
    x <- apply(x, MARGIN = 2, FUN = stringr::str_trim) # Trim whitespace
    "Clean up the column names"
    x[,1] <- stringr::str_replace_all(x[,1], "[:,\\(\\)]", "") # Remove brackets, colons etc
    x[,1] <- stringr::str_replace_all(x[,1], "%", "percent")
    x[,1] <- stringr::str_to_title(x[,1])
    x[,1] <- stringr::str_replace_all(x[,1], "( |-)", "_") # Replace whitespace & '-' with underscores
    # Clean up the values & return a data.frame
    x[,2] <- stringr::str_replace_all(x[,2], "%", "")
    x <- structure(as.list(x[,2]), names = x[,1])
    as.data.frame(x, stringsAsFactors = FALSE)
  })
  #Merge all files into a single df
  df <- dplyr::bind_rows(ln)
  timeCols <- grepl("On$", names(df))
  df[timeCols] <- lapply(df[timeCols], lubridate::parse_date_time, orders = "b! d! HMS")
  df[!timeCols] <- lapply(df[!timeCols], as.numeric)
  intCols <- grepl("Number", names(df))
  df[intCols] <- lapply(df[intCols], as.integer)
  names(df) <- gsub("^(Number_Of_Splices_[ACGT])([acgt])\\.([AGCT])([acgt])$",
                    "\\1\\U\\2/\\3\\U\\4",
                    names(df), perl = TRUE)
  # Add the filename & additional columns
  df$Filename <- basename(x)
  df$Mapping_Duration <- with(df, Finished_On - Started_Mapping_On)
  df$Total_Mapped_Percent <- with(df, 100*(Uniquely_Mapped_Reads_Number + Number_Of_Reads_Mapped_To_Multiple_Loci) / Number_Of_Input_Reads)
  df <- dplyr::select(df, Filename,
                      dplyr::starts_with("Total"),
                      dplyr::contains("Input"),
                      dplyr::contains("Mapped"),
                      dplyr::contains("Splice"),
                      dplyr::ends_with("On"),
                      dplyr::contains("Mapping"),
                      dplyr::everything())

  if (tidyNames){
    names(df) <- gsub("(Number_Of_|_Number)", "", names(df))
    names(df) <- gsub("Percent_Of_(.+)", "\\1_(%)", names(df))
  }

  tibble::as_tibble(df)
}
