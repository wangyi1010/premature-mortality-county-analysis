# Spatial-econometrics checks. Skipped if the heavier spatial packages are not
# installed, so the core suite still runs in a minimal environment.

skip_if_not_installed("sf")
skip_if_not_installed("spdep")
skip_if_not_installed("spatialreg")
skip_if_not_installed("usmapdata")

source(test_path("..", "..", "R", "spatial.R"))

raw_dir <- test_path("..", "..", "data", "raw")
df <- load_county_data(raw_dir)
sw <- build_spatial_weights(df)

test_that("spatial weights line up with the data", {
  expect_equal(nrow(sw$df), length(sw$listw$neighbours))
  expect_true(all(sw$df$fips == sw$geo$fips))
  expect_gt(nrow(sw$df), 2500)  # most counties match the geometry
})

test_that("OLS residuals are significantly spatially autocorrelated", {
  mor <- moran_residual_test(fit_mortality_model(sw$df), sw$listw)
  expect_gt(mor$I, 0.15)        # clear positive autocorrelation
  expect_lt(mor$p_value, 1e-10)
})

test_that("spatial models fit better than OLS", {
  models <- fit_spatial_models(sw$df, sw$listw)
  cmp <- spatial_comparison(models)
  ols_aic <- cmp$aic[cmp$model == "OLS"]
  expect_true(all(cmp$aic[cmp$model != "OLS"] < ols_aic))  # both beat OLS
  expect_gt(models$sar$rho, 0)     # positive spatial-lag parameter
  expect_gt(models$sem$lambda, 0)  # positive spatial-error parameter
})
