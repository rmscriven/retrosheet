# retrosheet
Import Retrosheet data as a structured R object

`retrosheet` is an R package that downloads and parses the single-season event, gamelog, roster, and schedule
files from http://www.retrosheet.org into structured R objects for further analysis.

## Changes from Master
* **Local Cache**: Use `getRetrosheet()` with the `cache` argument to pull data from a local file, instead of the retrosheet website
* **Improved Parsing**: Handles some edge cases in event data parsing that master struggles with

## Installation
This fork of `retrosheet` can be installed with:
```r
# install.packages("devtools")
devtools::install_github("colindouglas/retrosheet")
```

## Usage
* `getRetrosheet()` - This workhorse function returns the full seasonal data associated with the user-entered 
 arguments
    - For cached data, download the *.zip files from retrosheet and put them in a local folder with an identical structure to retrosheet. Then, call `getRetrosheet()` with the `cache` argument specified
    - If the `cache` argument is left empty, the function will retrieve data from the retrosheet website like previous versions
    - For example, if you want event log data from the 1957 Baltimore Orioles season, make sure the path `data/retrosheet/events/1957eve.zip` exists, then call: 
    
```r 
getRetrosheet(type = "play", year = 1957, team = "BAL", cache = "data/retrosheet")
```

* `getPartialGamelog()` - An alternative to returning the full gamelog files.  This function allows the user
 to choose the columns and date. Column names are made available by the global object `gamelogFields`
 
Also included are convenience functions 
* `getFileNames()` - for obtaining a list of all zip files currently available for use by this package
* `getTeamIDs()` - for providing the team ID value to be used in the `team` argument of `getRetrosheet()`
* `getParkIDs()` - for ballpark ID and name information


