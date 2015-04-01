.onAttach <- function(libname, pkgname) {

    packageStartupMessage("\nFor Retrosheet data obtained with this package:\n
The information used here was obtained free of charge from
and is copyrighted by Retrosheet. Interested parties may
contact Retrosheet at \"www.retrosheet.org\"\n")

}

.onLoad <- function(libname, pkgname) {
    load("R/sysdata.rda")
    options(retrosheet.glFields = retrosheetFields$gamelog)
}
