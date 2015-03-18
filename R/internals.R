.setColNames <- function(DATA) {
    ord <- with(retrosheetFields, eventOuter[eventOuter %in% names(DATA)])
    DATA <- DATA[ord]
    mapply(function(x, y) {
        if(!is.null(y)) colnames(x) <- y
        x
    }, DATA, with(retrosheetFields, eventInner[eventOuter %in% ord]))
}
