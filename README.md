`retrosheet` is an R package that parses and structures the game-log, play-by-play, 
and schedule data available for download from http://www.retrosheet.org.  

The event files at www.retrosheet.org/game.htm can be especially difficult to parse.
This package does the parsing on those files for you, returning the requested
event as a structured R object. It will retrieve the game-log and schedule 
files if specified, but is mainly a parser for the play-by-play files.

Installation:

`install.packages("devtools")
devtools::install_github("rmscriven/retrosheet")`
