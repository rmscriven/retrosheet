.setColNames <- function(DATA) {
    rf <- retrosheetFields
    ord <- rf$eventOuter[rf$eventOuter %in% names(DATA)]
    DATA <- DATA[ord]
    out <- mapply(
        function(x, y) {
            if(!is.null(y)) colnames(x) <- y
            x
        },
        x = DATA,
        y = rf$eventInner[rf$eventOuter %in% ord]
    )
    out
}
