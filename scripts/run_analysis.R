#!/usr/bin/env Rscript
# End-to-end analysis pipeline.
#
#   Rscript scripts/run_analysis.R
#
# Loads and cleans the data, fits the model, and writes every figure to
# outputs/figures/ plus a plain-text model summary to outputs/model_summary.txt.
# The RMarkdown report and the README both consume these artifacts.

source("R/data.R")
source("R/model.R")
source("R/plots.R")

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

message("Loading data ...")
df_all <- load_county_data("data/raw", complete_cases = FALSE)  # for the map
df <- load_county_data("data/raw")                              # modelling sample
message(sprintf("  %d counties in the complete-case modelling sample", nrow(df)))

message("Fitting model ...")
model <- fit_mortality_model(df)
glance <- model_glance(model)
std <- standardized_coefs(df)
vif <- vif_table(model)

message("Writing figures ...")
figs <- list(
  "coefficients.png"  = plot_std_coefs(std),
  "correlations.png"  = plot_correlations(df),
  "child_poverty.png" = plot_key_scatter(df),
  "actual_fitted.png" = plot_actual_fitted(model, df)
)
for (name in names(figs)) {
  ggplot2::ggsave(file.path("outputs/figures", name), figs[[name]],
                  width = 8, height = 5, dpi = 150, bg = "white")
}
ggplot2::ggsave("outputs/figures/mortality_map.png", plot_mortality_map(df_all),
                width = 9, height = 6, dpi = 150, bg = "white")

message("Writing model summary ...")
sink("outputs/model_summary.txt")
cat("Premature mortality at the US county level -- model summary\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M"), "\n\n")
cat(sprintf("N = %d counties | R-squared = %.3f | adjusted R-squared = %.3f\n\n",
            glance$n, glance$r_squared, glance$adj_r_squared))
cat("Standardised coefficients (strongest first):\n")
print(as.data.frame(std[, c("label", "std_coef")]), row.names = FALSE)
cat("\nVariance inflation factors:\n")
print(as.data.frame(vif[, c("label", "vif")]), row.names = FALSE)
cat("\nFull OLS summary:\n")
print(summary(model))
sink()

# --- Spatial econometrics (optional; needs sf/spdep/spatialreg/usmapdata) -----
spatial_ok <- all(vapply(c("sf", "spdep", "spatialreg", "usmapdata"),
                         requireNamespace, logical(1), quietly = TRUE))
if (spatial_ok) {
  message("Running spatial analysis ...")
  source("R/spatial.R")
  sw <- build_spatial_weights(df)
  mor <- moran_residual_test(fit_mortality_model(sw$df), sw$listw)
  smodels <- fit_spatial_models(sw$df, sw$listw)
  cmp <- spatial_comparison(smodels)

  ggplot2::ggsave("outputs/figures/moran_scatter.png",
                  plot_moran(fit_mortality_model(sw$df), sw$listw),
                  width = 8, height = 5, dpi = 150, bg = "white")

  sink("outputs/spatial_summary.txt")
  cat("Spatial analysis of premature mortality (US counties)\n")
  cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M"), "\n\n")
  cat(sprintf("Counties matched to geometry: %d (islands with no neighbour: %d)\n\n",
              nrow(sw$df), sw$n_islands))
  cat(sprintf("Moran's I on OLS residuals = %.3f (p = %.3g)\n", mor$I, mor$p_value))
  cat("  -> significant positive spatial autocorrelation: OLS errors are not\n")
  cat("     independent, so OLS standard errors are unreliable.\n\n")
  cat("Model comparison:\n")
  print(as.data.frame(cmp), row.names = FALSE)
  cat("\nSpatial error model (SEM) summary:\n")
  print(summary(smodels$sem))
  sink()
  message("  spatial outputs written")
} else {
  message("Skipping spatial analysis (sf/spdep/spatialreg/usmapdata not installed)")
}

message("Done. See outputs/figures/ and outputs/")
