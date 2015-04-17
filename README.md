# retrosheet
Import Retrosheet data as a structured R object

`retrosheet` is an R package that downloads and parses the single-season event, gamelog, roster, and schedule
files from http://www.retrosheet.org into structured R objects for further analysis.

Currently, the main functions are
 - `getRetrosheet()` - This workhorse function returns the full seasonal data associated with the user-entered 
 arguments
 - `getPartialGamelog()` - An alternative to returning the full gamelog files.  This function allows the user
 to choose the columns and date. Column names are made available by the global object `gamelogFields`
 
Also included are convenience functions 
 - `getFileNames()` - for obtaining a list of all zip files currently available for use by this package
 - `getTeamIDs()` - for providing the team ID value to be used in the `team` argument of `getRetrosheet()`
 - `getParkIDs()` - for ballpark ID and name information

`retrosheet` version 1.0.2 is now available on CRAN, and can be installed with

	install.packages("retrosheet")
	
This development version can be installed with 

	install.packages("devtools")
	devtools::install_github("rmscriven/retrosheet")
