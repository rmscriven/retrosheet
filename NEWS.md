# retrosheet 1.1.1
  * Added `get_retrosheet()`, a wrapper for `getRetrosheet()` that takes the same arguments and returns the same data, except coercing matrices into tibbles.
  * Updated tests to account for more data being added to retrosheet.org (whoops)

# retrosheet 1.1.0
  * Schedule scraping now expects a `*.zip` file instead of `*.txt` file, to accommodate change to retrosheet.org file structure
  * Added `cache` parameter to getRetrosheet(). This defaults to NA. If set to a local directory path, retrosheet data will be cached locally and re-used so as not to constantly download the same file from the retrosheet.org servers
  * Fixed parsing of substitutions in games where no substitutions occurred. This is a rare edge case.
  * Removed `RCurl` dependency (due to incompatibility with TLS > 1.0). Web data is now downloaded using `httr` functions
  * Removed `XML` dependency, replaced with `xml2` and `rvest`
