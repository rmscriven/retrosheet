#'
#' @title Partial parser for game-log files
#'
#' @description Choose the columns and rows
#'
#' @param year A single four-digit year.
#' @param glFields A subset of \code{getOption("retrosheet.glFields")}
#' @param date One of either NULL (the default), or a four-digit
#' character string identifying the date 'mmdd'
#' @param ... further arguments passed to \code{\link[utils]{download.file}}
#'
#' @export
#'
#' @return A data table with dimensions
#' \code{length(date)} x \code{length(glFields)}
#'
#' @examples ## Get Homerun and RBI info for August 25, 2012
#' f <- grep("HR|RBI", getOption("retrosheet.glFields"), value = TRUE)
#' getPartialGamelog(2012, glFields = f, date = "0825")
#'
getPartialGamelog <- function(
    year, glFields = getOption("retrosheet.glFields"), date = NULL, ...) {

    ## check 'glFields'
    if(identical(glFields, getOption("retrosheet.glFields"))) {
        stop(shQuote("getPartialGamelog"), " is for efficiently return a small subset of the entire file. For the full table, use ", shQuote("getRetrosheet(\"game\", year)"))
    }

    ## define the url
    u <- "http://www.retrosheet.org"
    full <- sprintf("%s/gamelogs/gl%s.zip", u, year)

    ## download the file
    tmp <- tempfile()
    on.exit(unlink(tmp))
    download.file(full, destfile = tmp, ...)

    ## extract the text file
    fname <- unzip(tmp, file = unzip(tmp, list = TRUE)$Name)
    on.exit(unlink(fname))

    ## match 'glFields' against the internal name vector
    fields <- retrosheetFields$gamelog
    sel <- union(1L, sort(match(glFields, fields)))

    ## read the data
    out <- if(is.null(date)) {
        data.table::fread(fname, select = sel, header = FALSE)
    } else {
        command <- sprintf("grep '%s' %s", paste0(year, date), fname)
        data.table::fread(command, header = FALSE, select = sel)
            #if(is.null(date)) fname else command,
    }

    ## set the names
    data.table::setnames(out, fields[sel])

    ## return the table
    out
}
