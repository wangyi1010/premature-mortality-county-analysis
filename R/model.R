# Modelling helpers: the OLS fit, standardised coefficients and VIF diagnostics.

suppressPackageStartupMessages({
  library(dplyr)
})

model_formula <- premature_aamort ~ pct_smokers + pct_obese + pct_uninsured +
  grad_rate + pct_child_poverty + opioid_rate_2016

#' Fit the multivariate OLS model of premature mortality.
#' @param df Output of load_county_data().
#' @return An lm object.
fit_mortality_model <- function(df) {
  lm(model_formula, data = df)
}

#' Standardised (z-scored) regression coefficients, sorted by magnitude.
#'
#' Fitting on z-scored variables makes the coefficients directly comparable as
#' effect sizes. Returns a tibble of term / std_coef ordered strongest first.
standardized_coefs <- function(df) {
  z <- as.data.frame(scale(df[, c("premature_aamort", predictor_vars)]))
  mz <- lm(model_formula, data = z)
  b <- coef(mz)[-1]
  tibble(
    term = names(b),
    label = variable_labels[names(b)],
    std_coef = as.numeric(b)
  ) %>% arrange(desc(abs(std_coef)))
}

#' Variance inflation factors for the fitted model (multicollinearity check).
#'
#' Computed directly from the definition VIF_j = 1 / (1 - R^2_j), where R^2_j is
#' from regressing predictor j on all the other predictors. Done by hand to avoid
#' a heavy dependency (car) for a one-line formula.
vif_table <- function(model) {
  X <- model.matrix(model)[, -1, drop = FALSE]  # drop intercept
  v <- vapply(seq_len(ncol(X)), function(j) {
    r2 <- summary(lm(X[, j] ~ X[, -j, drop = FALSE]))$r.squared
    1 / (1 - r2)
  }, numeric(1))
  names(v) <- colnames(X)
  tibble(term = names(v), label = variable_labels[names(v)], vif = as.numeric(v)) %>%
    arrange(desc(vif))
}

#' One-line numeric summary of the model (N, R2, adjusted R2).
model_glance <- function(model) {
  s <- summary(model)
  tibble(n = length(model$residuals),
         r_squared = s$r.squared,
         adj_r_squared = s$adj.r.squared)
}
