# retrosheet
Import Retrosheet data as a structured R object

`retrosheet` is an R package that downloads and parses the single-season event, gamelog, roster, and schedule
files from http://www.retrosheet.org into structured R objects for further analysis.

## Installation
This fork of `retrosheet` can be installed with:
```r
# install.packages("devtools")
devtools::install_github("colindouglas/retrosheet")
```

## Usage
* `getRetrosheet()` - This workhorse function returns the full seasonal data associated with the user-entered 
 arguments
    * Use the `cache` argument to save a local cache and avoid stressing retrosheet.org
* `getPartialGamelog()` - An alternative to returning the full gamelog files.  This function allows the user
 to choose the columns and date. Column names are made available by the global object `gamelogFields`
 
Also included are convenience functions 

* `getFileNames()` - for obtaining a list of all zip files currently available for use by this package
* `getTeamIDs()` - for providing the team ID value to be used in the `team` argument of `getRetrosheet()`
* `getParkIDs()` - for ballpark ID and name information


