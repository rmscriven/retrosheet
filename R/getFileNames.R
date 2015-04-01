#'
#' @title A list of current available Retrosheet downloads
#'
#' @description A convenience, returning the base file names of the
#' available downloads for the \code{year} and \code{type} arguments
#' in \code{getRetrosheet}.
#'
#' @return A named list of available single-season Retrosheet event and
#' game-log zip files, and schedule text files. These file names are
#' not intended to be passed to \code{getRetrosheet}, but is simply a
#' fast way to determine if the desired data is available.
#'
#' @name getFileNames
#'
#' @examples getFileNames()
#'
#' @export

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
