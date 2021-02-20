test_that("getTeamIDs returns the right number of teams", {

    expect_equal(length(getTeamIDs(2012)), 30)

    expect_equal(length(getTeamIDs(1954)), 16)
})
