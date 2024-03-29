context("sar_p2")

test_that("sar_p2 returns correct results", {
  skip_on_cran()
  fit <- sar_p2(galap)
  expect_equal(round(fit$AICc, 2), 191.71)
  expect_equal(as.vector(round(fit$par[2], 2)), 0.01)
  expect_is(fit, "sars")
  expect_match(fit$normaTest[[1]], "none")
  expect_error(sar_linear(5), "data must be a matrix or dataframe")
})


test_that("sar_p2 summary returns correct results", {
  fit <- sar_p2(galap, grid_start = "none")
  fs <- summary(fit)
  expect_equal(round(sum(fs$residuals), 1), 170.2)
  expect_output(str(fs), "List of 16")
  expect_is(fs, "summary.sars")
  expect_equal(fs$normaTest[[2]], "none")
  #with grid_start
  fit2 <- sar_p2(galap)
  fs2 <- summary(fit2)
  expect_equal(round(sum(fs2$residuals), 0), 170)
  expect_output(str(fs2), "List of 16")
  expect_is(fs2, "summary.sars")
  expect_equal(fs2$normaTest[[2]], "none")
})