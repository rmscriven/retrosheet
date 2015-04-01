#' @name getTeamIDs
#'
#' @title Retrieve team IDs for event files
#'
#' @description This function retrieves the team ID needed for the
#' \code{team} argument of \code{getRetrosheet("play", year, team)}.
#'
#' @param year A single valid four-digit numeric year.
#' @param ... further arguments passed to \code{\link[utils]{download.file}}.
#'
#' @return If the file exists, a named vector of IDs for the given year.
#' Otherwise \code{NA}.
#'
#' @details All currently available years can be retrieved with
#' \code{type.convert(substr(getFileNames()$event, 1L, 4L))}
#'
#' @export
#'
#' @examples getTeamIDs(2010)
#'
getTeamIDs <- function(year, quiet = TRUE, ...) {
    stopifnot(is.numeric(year))
    path <- sprintf("http://www.retrosheet.org/events/%deve.zip", year)
    if (RCurl::url.exists(path)) {
        tmp <- tempfile()
        on.exit(unlink(tmp))
        download.file(path, destfile = tmp, quiet = quiet, ...)
    } else {
        available <- substr(getFileNames()$event, 1L, 4L)
        return(match(year, type.convert(available)))
    }
    fname <- paste0("TEAM", year)
    unzip(tmp, files = fname)
    on.exit(unlink(fname), add = TRUE)
    read <- data.table::fread(fname, header = FALSE, drop = 2:3)
    out <- structure(read[[1L]], .Names = read[[2L]])
    out
}

