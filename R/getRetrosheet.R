#'
#' Import single-season retrosheet data as a structured R object
#'
#' This function downloads and parses data from \url{http://www.retrosheet.org}
#' for the game-log, event, (play-by-play), roster, and schedule files.
#'
#' @param type character.  This argument can take on either of "game" for
#' game-logs, "play" for play-by-play (a.k.a. event) data, "roster" for
#' team rosters, or "schedule" for the game schedule for the given year.
#' @param year integer. A valid four-digit year.
#' @param team character. Only to be used if \code{type = "play"}.
#' A single valid team ID for the given year. For available team IDs for the
#' given year call \code{getTeamIDs(year)}.  The available teams
#' are in the "TeamID" column.
#' @param schedSplit One of "Date", "HmTeam", or "TimeOfDay" to return a list
#' split by the given value, or NULL (the default) for no splitting.
#' @param stringsAsFactors logical. The \code{stringsAsFactors} argument as
#' used in \code{\link[base]{data.frame}}. Currently applicable to types "game" and "schedule".
#' @param cache character. Path to locale cache of retrosheet data. If file doesn't exist,
#' files will be saved locally for future use. Defaults to "NA" so as not to save local data without
#' explicit permission#'
#' @return The following return values are possible for the given \code{type}
#' \itemize{
#' \item \code{game} - a data frame of gamelog data for the given year
#' \item \code{play} - a list, each element of which is a single game's play-by-play
#' data for the given team and year.  Each list element is also a list, containing
#' the play-by-play data split into individual matrices.
#' \item \code{roster} - a named list, each element containing the roster
#' for the named team for the given year, as a data frame.
#' \item \code{schedule} - a data frame containing the game schedule for the given year
#' }
#'
#' @examples
#' ## get the full 1995 season schedule
#' getRetrosheet("schedule", 1995)
#' \dontrun{
#' ## get the same schedule, split by time of day
#' getRetrosheet("schedule", 1995, schedSplit = "TimeOfDay")
#'
#' ## get the roster data for the 1995 season, listed by team
#' getRetrosheet("roster", 1995)
#'
#' ## get the full gamelog data for the 2012 season
#' getRetrosheet("game", 2012)
#'
#' ## get the play-by-play data for the San Francisco Giants' 2012 season
#' getRetrosheet("play", 2012, "SFN")
#' }
#'
#' @importFrom httr http_error GET write_disk
#' @importFrom stringi stri_split_fixed
#' @importFrom stats setNames
#' @importFrom utils read.csv unzip
#' @export

getRetrosheet <- function(type, year, team, schedSplit = NULL, stringsAsFactors = FALSE, cache = NA) {

    type <- match.arg(type, c("game", "play", "roster", "schedule"))

    if(type == "play" && missing(team)) {
        stop("argument 'team' must be supplied when 'type = \"play\"")
    }

    path <- switch(type,
        "game" = "/gamelogs/gl%d.zip",
        "play" = "/events/%deve.zip",
        "roster" = "/events/%deve.zip",
        "schedule" = "/schedule/%dSKED.ZIP")

    # If cache is NA, download to a temp location
    if (is.na(cache)) {
        fullPath <- sprintf(paste0("https://www.retrosheet.org", path), year)
        if(!http_error(fullPath)) {
            tmp <- tempfile()
            on.exit(unlink(tmp))
            GET(fullPath, write_disk(tmp, overwrite=TRUE))
        } else {
            stop(sprintf("'%s' is not a valid url or path", fullPath))
        }
    } else {
        # If the cache is something, then:

        # Drop trailing slash on cache path
        if (substring(cache, nchar(cache)) == "/") {
            cache <- substring(cache, 1, nchar(cache) - 1)
        }
        fullPath <- sprintf(paste0(cache, path), year)
        remotePath <- sprintf(paste0("https://www.retrosheet.org", path), year)
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

    if(type == "schedule") {
        zcon <- unz(tmp, filename = fname)
        out <- read.csv(zcon, header = FALSE, col.names = retrosheetFields$schedule,
                        stringsAsFactors = stringsAsFactors)
        if(is.character(schedSplit)) {
            schedSplit <- match.arg(schedSplit, c("Date", "HmTeam", "TimeOfDay"))
            out <- split(out, out[[schedSplit]])
        }
        closeAllConnections()
        return(out)
    }
    if(type == "game") {
        zcon <- unz(tmp, filename = fname)
        out <- read.csv(zcon, header = FALSE, col.names = retrosheetFields$gamelog,
            stringsAsFactors = stringsAsFactors)
        closeAllConnections()
        return(out)
    }

    if(type == "roster") {
        rosFiles <- grep(".ROS", fname, value = TRUE, fixed = TRUE)
        read <- lapply(rosFiles, function(x) {
            zcon <- unz(tmp, filename = x)
            o <- read.csv(zcon, header = FALSE, col.names = retrosheetFields$roster,
                stringsAsFactors = stringsAsFactors)
            o
        })
        out <- setNames(read, substr(rosFiles, 1L, 3L))
        closeAllConnections()
        return(out)
    }
    zcon <- unz(tmp, filename = paste0("TEAM", year))
    allTeams <- readLines(zcon)
    team <- match.arg(team, substr(allTeams, 1L, 3L))
    closeAllConnections()

    # function for single game parsing
    doGame <- function(x) {
        sc <- scan(text = x, sep = ",", what = "", flush = TRUE, quiet = TRUE)
        outer <- retrosheetFields$eventOuter
        v <- vector("list", 8L)
        for(i in seq_len(8L)) {
            sx <- substr(x, regexpr(",", x, fixed = TRUE) + 1L, nchar(x))
            v[[i]] <- sx[match(sc, outer) == i]
        }
        names(v) <- outer
        v[-c(1:2, 6L)] <- lapply(v[-c(1:2, 6L)], stri_split_fixed, ",", simplify = TRUE)

        ans <- Map(function(A, B) {
            if (NCOL(A) == length(B) | is.null(dim(A))) {
                colnames(A) <- B; A
            } else { NULL }
        },  A = v, B = retrosheetFields$eventInner)
        ans
    }

    rgx <- paste(team, "EV", sep = ".")
    fnm <- grep(rgx, fname, value = TRUE, fixed = TRUE)
    zcon <- unz(tmp, filename = fnm)
    r <- readLines(zcon)
    g <- grepl("^id", r)
    sr <- unname(split(gsub("\"", "", r), cumsum(g)))
    res <- lapply(sr, doGame)
    closeAllConnections()
    res
}
