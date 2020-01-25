#' @name get_games
#'
#' @title NOT IMPLEMENTED Parse event strings from retrosheet play-by-play data
#' #'
#' @description Parses the strings describing plays returned from the
#' #' \code{play} element of of \code{getRetrosheet(type = "play")} or \code{get_retrosheet(type = "play")}
#'
#' @param play A play object from \code{getRetrosheet(type = "play")} or \code{get_retrosheet(type = "play")}
#'
#' @return A list of intepreted details from the event strings'
#'
#' @importFrom httr http_error GET write_disk
#' @export
#'
#' @examples \donttest{
#' plays <- get_retrosheet("play", 2012, "SFN")[[1]]$play
#' parse_play
#' (play)
#' }
#'

# Example data
# play <- retrosheet::get_retrosheet("play", 2012, "SFN")[[1]]$play

get_plays <- function(year, team = NA, cache = NA) {

    if (missing(year)) stop("Argument 'year' must be supplied")
    if (missing(team)) stop("Argument 'team' must be supplied")

    path <- paste0("/events/", year, "eve.zip")

    # If cache is NA, download to a temp location
    if (is.na(cache)) {
        fullPath <- paste0("https://www.retrosheet.org", path)
        if(!http_error(fullPath)) {
            tmp <- tempfile()
            on.exit(unlink(tmp))
            GET(fullPath, write_disk(tmp, overwrite=TRUE))
        } else {
            stop(fullPath, " is not a valid path")
        }
    } else {
        # If the cache is something, then:

        # Drop trailing slash on cache path
        if (substring(cache, nchar(cache)) == "/") {
            cache <- substring(cache, 1, nchar(cache) - 1)
        }
        fullPath <- paste0(cache, path)
        remotePath <- paste0("https://www.retrosheet.org", path)
        # If the file doesn't exist, download it
        if (!file.exists(fullPath)) {
            # Make the folder if it doesn't exist
            if (!dir.exists(dirname(fullPath))) {
                dir.create(dirname(fullPath), recursive = TRUE)
            }
            # Download the file to the folder
            message("Caching to: ", fullPath)
            GET(remotePath, write_disk(fullPath, overwrite=TRUE))
            #download.file(remotePath, destfile = fullPath, ...)
        } else {
            message("Using local cache: ", fullPath)
        }
        # Then use the locally downloaded file as the data source
        tmp <- fullPath
    }

    fname <- unzip(tmp, list = TRUE)$Name

    zcon <- unz(tmp, filename = paste0("TEAM", year))
    allTeams <- readLines(zcon)
    # Argument 'team' must be in the zip OR NA
    if (!(team %in% substr(allTeams, 1L, 3L) | is.na(team))) stop("Team not recognized!")
    closeAllConnections()

    # # function for single game parsing
    # doGame <- function(x) {
    #     sc <- scan(text = x, sep = ",", what = "", flush = TRUE, quiet = TRUE)
    #     outer <- retrosheetFields$eventOuter
    #     v <- vector("list", 8L)
    #     for(i in seq_len(8L)) {
    #         sx <- substr(x, regexpr(",", x, fixed = TRUE) + 1L, nchar(x))
    #         v[[i]] <- sx[match(sc, outer) == i]
    #     }
    #     names(v) <- outer
    #     v[-c(1:2, 6L)] <- lapply(v[-c(1:2, 6L)], stri_split_fixed, ",", simplify = TRUE)
    #
    #     ans <- Map(function(A, B) {
    #         if (NCOL(A) == length(B) | is.null(dim(A))) {
    #             colnames(A) <- B; A
    #         } else { NULL }
    #     },  A = v, B = retrosheetFields$eventInner)
    #     ans
    # }

    unzip_team <- function(team) {
        fnm <- paste0(year, team, ".EVA")
        zcon <- unz(tmp, filename = fnm)
        r <- readLines(zcon)
        starts <- c(which(grepl("^id", r)), length(r))
        i <- 1
        game <- r[starts[i]:starts[i + 1] - 1]
        info <- read.csv(textConnection(game[grepl("^(info)", game)]), col.names = c("drop", "category", "info"))[, -1]
        pbp <-  read.table(textConnection(game[grepl("^(play)|^(sub)", game)]), header = FALSE, fill = TRUE, sep = ",")


    }


    g <- grepl("^id", r)
    sr <- unname(split(gsub("\"", "", r), cumsum(g)))
    res <- lapply(sr, doGame)
    closeAllConnections()
    res
    return(NULL) # Not implemented
}
