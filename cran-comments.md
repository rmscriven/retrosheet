## Test environments
* xubuntu 19.10 (local), R 3.6.2 and R-devel
* windows 10 (virtual machine), R 3.6.2 and R-devel

## R CMD check results
Duration: 31.2s
0 errors | 0 warnings | 0 notes 


## Downstream dependencies
None

## Maintainer Change
Updated version of prior package, archived 2016-12-30. Re-submitted to CRAN with permission from previous maintainer, Richard M. Scriven <rmscriven@gmail.com>. 

## R-Hub Notes:
* "Package was archived on CRAN"
    * Transfer of package to new maintainer
    
* Possibly mis-spelled words in DESCRIPTION: sabermetric (20:38)  
    * https://en.wikipedia.org/wiki/Sabermetrics
    
* Examples with CPU (user + system) or elapsed time > 5s: getparkIDs()
    * Requires downloading from retrosheet.org, depends on server latency and load
