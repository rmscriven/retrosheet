#'
#' Files currently available for download
#'
#' A convenience function, returning the base file names of the
#' available downloads for the \code{year} and \code{type} arguments
#' in \code{getRetrosheet}.
#'
#' @return A named list of available single-season Retrosheet event and
#' game-log zip files, and schedule text files. These file names are
#' not intended to be passed to \code{getRetrosheet}, but is simply a
#' fast way to determine if the desired data is available.
#'
#' @examples getFileNames()
#'
#' @importFrom httr GET content
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes
#' @importFrom stringr str_extract
#'
#' @export

getFileNames <- function() {
    paths <- c(event = "game.htm",
               gamelog = "gamelogs/index.html",
               schedule = "schedule/index.html")

    full <- paste0("https://www.retrosheet.org/", paths)

    docs <- lapply(full, function(x) {
        content <- GET(x)
        read_html(content, asText = TRUE)
    })

    get_links <- function(x) html_attr(html_nodes(x, "a"), "href")
    links <- lapply(docs, get_links)

    trim_path <- function(x) {
        out <- str_extract(x, pattern = "(gl[0-9]{4}|[0-9]{4}SKED|[0-9]{4}eve)(.zip|.ZIP)")
        out[!is.na(out)]
    }

    trimmed <- lapply(links, trim_path)

    names(trimmed) <- names(paths)
    trimmed
}
