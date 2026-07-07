# Regression tests that pin the headline results, so a refactor or a data swap
# that silently changes the analysis will fail loudly.

# testthat runs with the working directory at tests/testthat, so reach the raw
# data relative to that.
raw_dir <- test_path("..", "..", "data", "raw")
df <- load_county_data(raw_dir)

test_that("cleaning yields the expected county sample and columns", {
  expect_true(all(c("FIPS", analysis_vars) %in% names(df)))
  expect_equal(nrow(df), 2611)
  expect_false(anyNA(df[, analysis_vars]))
})

test_that("FIPS codes are real counties, not state/national aggregates", {
  expect_true(all(df$FIPS > 1000))
  expect_true(all(df$FIPS %% 1000 != 0))
})

test_that("model explains ~73% of variance in premature mortality", {
  g <- model_glance(fit_mortality_model(df))
  expect_equal(g$n, 2611)
  expect_equal(g$r_squared, 0.732, tolerance = 0.005)
})

test_that("child poverty is the strongest standardised predictor", {
  std <- standardized_coefs(df)
  expect_equal(std$term[1], "pct_child_poverty")
  expect_gt(std$std_coef[1], std$std_coef[2])
  # every predictor points in the expected (positive) direction
  expect_true(all(std$std_coef > 0))
})
