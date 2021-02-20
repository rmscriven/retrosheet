test_that("getParkIDs returns the right results", {
  park_ids <- getParkIDs()

  expect_equal(ncol(park_ids), 2)
  expect_equal(nrow(park_ids), 254)
})
