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
#' @importFrom stringr str_sub str_split
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

get_games <- function(year, team) {

    # The string that represents the pitch seqence
    pitches <- play$pitches

    # The string that represents the play
    play_string <- play$play


# Strikeouts --------------------------------------------------------------

    # A strikeout if it's just "K"
    is_strikeout <- play_string == "K"

    # It's a swinging strikeout if the last pitch is a strike
    is_KS <- ifelse(is_strikeout, str_sub(pitch_string, start = -1) == "S", NA)

    # It's a strikeout looking if the last pitch is a called strike
    is_KL <- ifelse(is_strikeout, str_sub(pitch_string, start = -1) == "C", NA)

    # Something is wrong if it's a strikeout but it's not a swinging or called strike
    something_wrong <- is_strikeout & !(is_KS | is_KL)

    if (!all(!something_wrong)) warning("Something is wrong with strikeouts")


# In Play Outs ------------------------------------------------------------

    is_inplay_out <- grepl("^[0-9]+", play_string)

    made_out <- unlist(ifelse(is_inplay_out,
                       map(str_split(play_string, pattern = "/"), ~ .[[1]]),
                       NA))

return(NULL) # Not implemented
}
