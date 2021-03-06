#' @title Colours for PASS/WARN/FAIL
#'
#' @description Default colours for PASS/WARN/FAIL
#'
#' @details \code{pwf} is an object of class PwfCols supplied with the package and used as the default colouring.
#' Colours correspond approximately to PASS, WARN and FAIL from the FASTQC reports,
#' with the additional colour (MAX) included to indicate an extreme FAIL.
#' In order, these colours in the default vector are green (\code{rgb(0, 0.8, 0)}),
#' yellow (\code{rgb(0.9, 0.9, 0.2)}), red (\code{rgb(0.8, 0.2, 0.2)}) and white
#' (\code{rgb(1, 1, 1)})
#'
#' @examples
#' # Make a pie chart showing the default colours
#' pie(rep(1,4), labels = names(pwf), col = getColours(pwf))
#'
#' @export
pwf <- new("PwfCols",
           PASS = rgb(0, 0.8,0),
           WARN = rgb(0.9, 0.9, 0.2),
           FAIL = rgb(0.8, 0.2, 0.2),
           MAX = rgb(1, 1, 1))
