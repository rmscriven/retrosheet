test_that("getPartialGamelog examples all work", {
    f <- grep("HR|RBI|Park", gamelogFields, value = TRUE)

    example_1 <- getPartialGamelog(2012, glFields = f)
    example_2 <- getPartialGamelog(glFields=f, date = "20120825")

    expect_equal(nrow(example_1), 2430)
    expect_equal(ncol(example_1), 8)


    expect_equal(nrow(example_2), 14)
    expect_equal(ncol(example_2), 8)
})
