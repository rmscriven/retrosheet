#'
#' Import single-season retrosheet data as tibbles
#'
#' This function is a wrapper for getRetrosheet(). It downloads and parses data from
#' \url{http://www.retrosheet.org} for the game-log, event, (play-by-play), roster, and schedule files.
#' While getRetrosheet() returns a list of matrices, this function returns an otherwise-identical list of tibbles.
#' It takes the same arguments, and mcan act as a drop-in replacement.
#'
#' @param type character.  This argument can take on either of "game" for
#' game-logs, "play" for play-by-play (a.k.a. event) data, "roster" for
#' team rosters, or "schedule" for the game schedule for the given year.
#'
#' @param ... Further arguments passed to getRetrosheet()
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
#' @examples
#' \donttest{
#' ## get the full 1995 season schedule
#' get_retrosheet("schedule", 1995)
#'
#' ## get the same schedule, split by time of day
#' get_retrosheet("schedule", 1995, schedule_split = "TimeOfDay")
#'
#' ## get the roster data for the 1995 season, listed by team
#' get_retrosheet("roster", 1995)
#'
#' ## get the full gamelog data for the 2012 season
#' get_retrosheet("game", 2012)
#'
#' ## get the play-by-play data for the San Francisco Giants' 2012 season
#' get_retrosheet("play", 2012, "SFN")
#' }
#'
#' @importFrom purrr map
#' @importFrom tibble as_tibble
#' @importFrom lubridate ymd
#' @importFrom readr col_guess cols
#' @export

get_retrosheet <- function(type, ...) {

    # type <- "play"; year = 2012; team = "SFN"; schedSplut = NULL;  cache = NA
    # type <- "schedule"; year = 1995; team = "SFN"; schedSplit = NULL; cache = NA
    # response <- getRetrosheet("roster", 1995, cache = "testdata"); type = "roster"
    # response <- getRetrosheet(type = "schedule", year = 1995, schedSplit = "TimeOfDay")
    # response <- getRetrosheet("play", 2012, "SFN", cache = "testdata")
    # response <- getRetrosheet(type = "schedule", year = 1995, schedSplit = "TimeOfDay")
    # response <- getRetrosheet(type = "schedule", year = 1995)
    # response <- getRetrosheet("schedule", 1995, cache = "testdata")
    response <- getRetrosheet(type, ...)

    matrix_to_tibble <- function(x) {
        if (is.matrix(x) | is.data.frame(x)) {
            out <- as_tibble(x, col_types = col_guess())
            if ("Date" %in% colnames(out)) {
                out$Date <- ymd(out$Date)
            }
            out
        } else if (length(x) > 1) {
            map(x, matrix_to_tibble)
        } else {
            x
        }
    }

    matrix_to_tibble(response)

}
