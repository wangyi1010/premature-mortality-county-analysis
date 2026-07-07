# Spatial econometrics: does county premature mortality violate the OLS
# assumption of independent errors, and if so, do spatial models fit better?
#
# County-level (ecological) data are almost always spatially autocorrelated:
# neighbouring counties share unobserved regional factors (economy, climate,
# state policy, culture). If the OLS residuals are spatially autocorrelated the
# standard errors are wrong and the model is misspecified. Here we test for it
# (Moran's I) and fit a spatial lag (SAR) and spatial error (SEM) model.
#
# Depends on sf, spdep, spatialreg and usmapdata (county geometry). These are
# heavier than the core analysis, so this module is optional: run_analysis.R
# skips it gracefully if the packages are absent.

suppressPackageStartupMessages({
  library(dplyr)
})

#' Build a row-standardised spatial weights matrix for the analysis counties.
#'
#' Uses queen contiguity (counties sharing an edge or corner are neighbours) on
#' usmapdata's bundled county geometry, restricted to the counties present in
#' `df`. Returns the data frame re-ordered to match the geometry, so the weights
#' line up row-for-row with the model data.
#'
#' @param df Modelling frame from load_county_data() (must contain FIPS).
#' @return list(df, listw, nb, geo, n_islands).
build_spatial_weights <- function(df) {
  stopifnot("FIPS" %in% names(df))
  suppressPackageStartupMessages({
    library(sf); library(spdep); library(usmapdata)
  })

  df$fips <- sprintf("%05d", as.integer(df$FIPS))
  geo <- usmapdata::us_map(regions = "counties")
  geo <- geo[geo$fips %in% df$fips, ]
  geo <- geo[order(geo$fips), ]
  geo <- sf::st_make_valid(geo)

  df <- df[match(geo$fips, df$fips), ]        # align data to geometry order
  stopifnot(all(geo$fips == df$fips))

  nb <- spdep::poly2nb(geo, queen = TRUE)
  # zero.policy keeps island counties (no land neighbour, e.g. Nantucket) in the
  # analysis with a zero-weight row rather than dropping them.
  listw <- spdep::nb2listw(nb, style = "W", zero.policy = TRUE)

  list(df = df, listw = listw, nb = nb, geo = geo,
       n_islands = sum(spdep::card(nb) == 0))
}

#' Moran's I test for spatial autocorrelation in a model's residuals.
#' @return list(I, p_value, htest) where htest is the full spdep object.
moran_residual_test <- function(model, listw) {
  suppressPackageStartupMessages(library(spdep))
  mt <- spdep::lm.morantest(model, listw, zero.policy = TRUE)
  list(I = unname(mt$estimate[1]), p_value = mt$p.value, htest = mt)
}

#' Fit OLS, spatial-lag (SAR) and spatial-error (SEM) models on the same data.
#' @return named list of fitted models: ols, sar, sem.
fit_spatial_models <- function(df, listw) {
  suppressPackageStartupMessages(library(spatialreg))
  list(
    ols = fit_mortality_model(df),
    sar = spatialreg::lagsarlm(model_formula, data = df, listw = listw, zero.policy = TRUE),
    sem = spatialreg::errorsarlm(model_formula, data = df, listw = listw, zero.policy = TRUE)
  )
}

#' Tidy comparison of the three models: fit and the spatial parameter.
#' @param models Output of fit_spatial_models().
#' @return tibble(model, aic, spatial_param, estimate).
spatial_comparison <- function(models) {
  tibble(
    model = c("OLS", "Spatial lag (SAR)", "Spatial error (SEM)"),
    aic = c(AIC(models$ols), AIC(models$sar), AIC(models$sem)),
    spatial_param = c(NA_character_, "rho (spatial lag)", "lambda (spatial error)"),
    estimate = c(NA_real_, models$sar$rho, models$sem$lambda)
  )
}
