#'
#' @title Import Retrosheet data as a structured R object
#'
#' @description This function downloads and parses data from
#' \url{http://www.retrosheet.org} for the gamelog, play-by-play
#' (a.k.a. event), roster, and schedule files.
#'
#' @param type character.  This argument can take on either of "game" for
#' game-logs, "play" for play-by-play (a.k.a. event) data, "roster" for
#' team rosters, or "schedule" for the game schedule for the given year.
#' @param year integer. A valid four-digit year.
#' @param team character. Only to be used if \code{type = "play"}.
#' A single valid team ID for the given year. For available team IDs for the
#' given year call \code{getRetrosheetTeamData(year)}.  The available teams
#' are in the "TeamID" column.
#' @param stringsAsFactors logical. The \code{stringsAsFactors} argument as
#' used in \code{\link[base]{data.frame}}. Currently applicable to types "game" and "schedule".
#' @param ... further arguments passed to \code{\link[utils]{download.file}}.
#'
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
#' @author Ananda Mahto
#' @author Richard Scriven
#'
#' @examples
#' \dontrun{
#'
#' ## gamelog data for the 2012 season
#' getRetrosheet("game", 2012)
#' ## play-by-play data for the San Francisco Giants for the 2012 season.
#' ## For most seasons, returns a length-81 list with seven elements each,
#' ## one team's entire home-half season.
#' getRetrosheet("play", 2012, "SFN")
#' }
#'
#' @importFrom RCurl url.exists
#'
#' @export
getRetrosheet <- function(type, year, team, stringsAsFactors = FALSE, ...) {

    type <- match.arg(type, c("game", "play", "roster", "schedule"))

    if(type == "play" && missing(team)) {
        stop('argument team must be supplied when type = "play"')
    }

    u <- "http://www.retrosheet.org"

    path <- switch(type,
        "game" = "/gamelogs/gl%d.zip",
        "play" = "/events/%deve.zip",
        "roster" = "/events/%deve.zip",
        "schedule" = "/schedule/%dsked.txt")

    fullPath <- sprintf(paste0(u, path), year)

    if(url.exists(fullPath)) {

        if(type == "schedule") {
            out <- read.csv(fullPath, header = FALSE,
                col.names = retrosheetFields$schedule,
                stringsAsFactors = stringsAsFactors)
            return(out)
        }

        tmp <- tempfile()
        on.exit(unlink(tmp))
        download.file(fullPath, destfile = tmp, ...)

    } else {
        stop(sprintf("'%s' is not a valid url", fullPath))
    }

    fname <- unzip(tmp, list = TRUE)$Name

    if(type == "game") {
        out <- read.csv(unz(tmp, filename = fname), header = FALSE,
            col.names = retrosheetFields$gamelog,
            stringsAsFactors = stringsAsFactors)
        return(out)
    }

    if(type == "roster") {
        rosFiles <- grep(".ROS", fname, value = TRUE, fixed = TRUE)
        read <- lapply(rosFiles, function(x) {
            read.csv(unz(tmp, filename = x), header = FALSE,
                col.names = retrosheetFields$roster,
                stringsAsFactors = stringsAsFactors)
        })
        out <- setNames(read, substr(rosFiles, 1L, 3L))
        return(out)
    }

    allTeams <- readLines(unz(tmp, filename = paste0("TEAM", year)))
    team <- match.arg(team, substr(allTeams, 1L, 3L))

    rgx <- paste(team, "EV", sep = ".")
    f <- grep(rgx, fname, value = TRUE, fixed = TRUE)
    rawData <- readLines(unz(tmp, filename = f))
    DE <- strsplit(rawData, ",", fixed = TRUE)
    Ids <- vapply(DE, `[`, character(1L), 1L) == "id"
    Step1 <- unname(split(DE, cumsum(Ids)))
    Step2 <- lapply(Step1, function(x){
        split(x, vapply(x, `[`, character(1L), 1L))
    })
    Step3 <- lapply(Step2, function(x){
        lapply(x, function(y) suppressWarnings(do.call(rbind, y)))
    })
    Step4 <- rapply(Step3, `[`, how = "list", ..1 = , ..2 = -1L)
    Step5 <- rapply(Step4, gsub, how = "list", pattern = '"', replacement = "")
    out <- lapply(Step5, .setColNames)
    names(out) <- paste0("game", seq_along(out))
    out
}
