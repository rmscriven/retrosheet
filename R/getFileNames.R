#'
#' @title Retrieve a list of current available downloads
#'
#' @description This function is for convenience, and returns the file names
#' of available downloads for the \code{year} and \code{type} arguments
#' in \code{getRetrosheet()}
#'
#' @return a named list of available Retrosheet zip and text files
#'
#' @name getFileNames
#' @export
#'
getFileNames <- function() {
    path <- c(event = "game.htm", gamelog = "gamelogs/index.html",
        schedule = "schedule/index.html")
    full <- paste("http://www.retrosheet.org", path, sep = .Platform$file.sep)
    curl <- RCurl::getCurlHandle()
    docs <- lapply(full, function(x) {
        content <- RCurl::getURL(x, curl = curl)
        XML::htmlParse(content, asText = TRUE)
    })
    o <- function(pat, doc) {
        fnames  <- XML::xpathSApply(doc,
            path = "(//pre//a | //b/a)/@href", fun = basename)
        grep(pat, fnames, value = TRUE)
    }
    part <- sprintf(c("%seve.zip", "gl%s.zip", "%ssked.txt"), "\\d+")
    res <- setNames(Map(o, part, docs), names(path))
    lapply(docs, XML::free)
    res
}


#' @name getTeamData
#'
#' @title Retrieve a data frame of team information
#'
#' @description This function is for convenience, and returns a data frame of
#' team information, including team IDs, for the \code{team} argument in \code{getRetrosheet()}.
#'
#' @param year integer. A valid four-digit year.
#' @param ... further arguments passed to \code{\link[utils]{download.file}}.
#'
#' @return a data frame of team info for the given year
#'
#' @export
#'
getTeamData <- function(year, ...) {
    path <- sprintf("http://www.retrosheet.org/events/%deve.zip", year)
    if(RCurl::url.exists(path)) {
        tmp <- tempfile()
        on.exit(unlink(tmp))
        download.file(path, destfile = tmp, ...)
    } else {
        stop("Given year not found in retrosheet.org event database")
    }
    read.csv(unz(tmp, filename = paste0("TEAM", year)), header = FALSE,
        col.names = c("TeamID", "LeagueID", "City", "Name"), stringsAsFactors = FALSE)
}

