# ggplot figure builders. Each returns a ggplot object so callers decide how to
# render (interactive, PNG for the README, or PDF inside the report).

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})

theme_set(theme_minimal(base_size = 12))

PALETTE <- list(accent = "#B2182B", neutral = "grey35", fit = "#2166AC")

#' Horizontal bar chart of standardised coefficients (the headline figure).
plot_std_coefs <- function(std_df) {
  std_df %>%
    mutate(label = factor(label, levels = rev(label))) %>%
    ggplot(aes(std_coef, label)) +
    geom_col(fill = PALETTE$accent, width = 0.65) +
    geom_text(aes(label = sprintf("%.2f", std_coef)),
              hjust = -0.15, size = 3.5, colour = PALETTE$neutral) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
    labs(x = "Standardised coefficient", y = NULL,
         title = "Child poverty is the strongest predictor of premature mortality",
         subtitle = "OLS coefficients on z-scored county-level variables") +
    theme(plot.title.position = "plot")
}

#' Correlation heatmap among the outcome and predictors.
plot_correlations <- function(df) {
  cm <- cor(df[, analysis_vars], use = "complete.obs")
  cd <- as.data.frame(as.table(cm))
  names(cd) <- c("x", "y", "r")
  ggplot(cd, aes(x, y, fill = r)) +
    geom_tile(colour = "white") +
    geom_text(aes(label = sprintf("%.2f", r)), size = 2.8) +
    scale_fill_gradient2(low = PALETTE$fit, mid = "white", high = PALETTE$accent,
                         midpoint = 0, limits = c(-1, 1)) +
    scale_x_discrete(labels = function(v) variable_labels[v]) +
    scale_y_discrete(labels = function(v) variable_labels[v]) +
    labs(x = NULL, y = NULL, fill = "r",
         title = "Correlations among mortality and its predictors") +
    theme(axis.text.x = element_text(angle = 40, hjust = 1),
          plot.title.position = "plot")
}

#' Scatter of the strongest predictor (child poverty) vs mortality.
plot_key_scatter <- function(df) {
  ggplot(df, aes(pct_child_poverty, premature_aamort)) +
    geom_point(alpha = 0.25, colour = PALETTE$neutral, size = 0.9) +
    geom_smooth(method = "lm", formula = y ~ x, colour = PALETTE$accent, se = TRUE) +
    labs(x = variable_labels["pct_child_poverty"],
         y = variable_labels["premature_aamort"],
         title = "Premature mortality rises steeply with child poverty") +
    theme(plot.title.position = "plot")
}

#' County choropleth of premature age-adjusted mortality.
#'
#' Uses usmap's bundled, FIPS-keyed county geometry (Alaska and Hawaii inset), so
#' no shapefile is downloaded at runtime. Expects the full merged frame; counties
#' missing the outcome are left unfilled (grey).
plot_mortality_map <- function(df) {
  map_df <- data.frame(
    fips = sprintf("%05d", as.integer(df$FIPS)),
    value = df$premature_aamort
  )
  usmap::plot_usmap(regions = "counties", data = map_df, values = "value",
                    color = NA, linewidth = 0) +
    ggplot2::scale_fill_viridis_c(
      option = "magma", direction = -1, na.value = "grey90",
      name = "Deaths\nper 100,000") +
    ggplot2::labs(
      title = "Premature age-adjusted mortality by US county",
      subtitle = "County Health Rankings, 2018") +
    ggplot2::theme(legend.position = "right",
                   plot.title.position = "plot")
}

#' Moran scatterplot of OLS residuals against their spatial lag.
#'
#' The slope of the fitted line is Moran's I; a clear positive slope is the
#' visual signature of spatially autocorrelated residuals (nearby counties have
#' similar errors), which violates the OLS independence assumption.
plot_moran <- function(model, listw) {
  resid_std <- as.numeric(scale(residuals(model)))
  lag_resid <- spdep::lag.listw(listw, resid_std, zero.policy = TRUE)
  d <- data.frame(resid = resid_std, lag = lag_resid)
  moran_i <- coef(lm(lag ~ resid, data = d))[2]
  ggplot(d, aes(resid, lag)) +
    geom_point(alpha = 0.25, colour = PALETTE$neutral, size = 0.9) +
    geom_hline(yintercept = 0, colour = "grey70") +
    geom_vline(xintercept = 0, colour = "grey70") +
    geom_smooth(method = "lm", formula = y ~ x, colour = PALETTE$accent, se = FALSE) +
    labs(x = "Standardised OLS residual",
         y = "Spatial lag of residual",
         title = sprintf("Spatial autocorrelation in the residuals (Moran's I = %.2f)", moran_i),
         subtitle = "Nearby counties have similar model errors — OLS independence is violated") +
    theme(plot.title.position = "plot")
}

#' Actual vs fitted values, to show overall model fit.
plot_actual_fitted <- function(model, df) {
  d <- data.frame(actual = df$premature_aamort, fitted = fitted(model))
  ggplot(d, aes(fitted, actual)) +
    geom_point(alpha = 0.25, colour = PALETTE$neutral, size = 0.9) +
    geom_abline(slope = 1, intercept = 0, colour = PALETTE$accent, linewidth = 0.8) +
    labs(x = "Fitted premature mortality (per 100,000)",
         y = "Observed premature mortality (per 100,000)",
         title = "Model fit: observed vs predicted") +
    theme(plot.title.position = "plot")
}
