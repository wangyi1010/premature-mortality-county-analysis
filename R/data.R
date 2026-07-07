# Data loading, merging and cleaning for the premature-mortality analysis.
#
# The two raw inputs live in data/raw:
#   * County Health Rankings 2018 (.xls) -- outcome + five internal predictors
#   * CDC county opioid dispensing rate 2016 (.csv) -- one external predictor
#
# load_county_data() returns one tidy tibble, one row per US county, with the
# outcome and six predictors coerced to numeric. All the fragile "which sheet /
# which column" knowledge is isolated here so the rest of the project never
# touches raw spreadsheet layout.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
})

# Human-readable labels for every analysis variable, used by tables and plots.
variable_labels <- c(
  premature_aamort  = "Premature age-adjusted mortality (per 100,000)",
  pct_smokers       = "Adult smoking (%)",
  pct_obese         = "Adult obesity (%)",
  pct_uninsured     = "Uninsured (%)",
  grad_rate         = "High-school graduation rate (%)",
  pct_child_poverty = "Children in poverty (%)",
  opioid_rate_2016  = "Opioid dispensing rate, 2016 (per 100)"
)

analysis_vars <- names(variable_labels)
predictor_vars <- setdiff(analysis_vars, "premature_aamort")

#' Load, merge and clean the county-level dataset.
#'
#' @param raw_dir Directory holding the two raw files (default "data/raw").
#' @param complete_cases If TRUE (default) drop rows with any missing analysis
#'   variable, giving the modelling sample; if FALSE keep all merged counties.
#' @return A tibble with columns FIPS + the seven analysis variables.
load_county_data <- function(raw_dir = "data/raw", complete_cases = TRUE) {
  chr_path <- file.path(raw_dir, "county_health_rankings_2018.xls")
  op_path  <- file.path(raw_dir, "opioid_prescribing_2016.csv")

  # Outcome: premature age-adjusted mortality (Sheet 6, "Age-Adjusted Mortality").
  dv <- read_excel(chr_path, sheet = 6, skip = 2, col_names = FALSE)[, c(1, 5)]
  names(dv) <- c("FIPS", "premature_aamort")

  # Internal predictors (Sheet 4, "Ranked Measure Data").
  iv <- read_excel(chr_path, sheet = 4, skip = 2, col_names = FALSE)[, c(1, 31, 35, 68, 105, 117)]
  names(iv) <- c("FIPS", "pct_smokers", "pct_obese", "pct_uninsured",
                 "grad_rate", "pct_child_poverty")

  # External predictor: CDC county opioid dispensing rate, 2016.
  op <- read_csv(op_path, show_col_types = FALSE)[, c(3, 4)]
  names(op) <- c("FIPS", "opioid_rate_2016")

  county <- dv %>%
    left_join(iv, by = "FIPS") %>%
    mutate(FIPS = as.numeric(FIPS)) %>%
    left_join(mutate(op, FIPS = as.numeric(FIPS)), by = "FIPS") %>%
    # Keep counties only: drop national/state aggregate rows (FIPS <= 1000 or
    # ending in 000, which are state totals).
    filter(!is.na(FIPS), FIPS > 1000, FIPS %% 1000 != 0) %>%
    mutate(across(-FIPS, ~ suppressWarnings(as.numeric(.)))) %>%
    select(FIPS, all_of(analysis_vars))

  if (complete_cases) {
    county <- tidyr::drop_na(county, all_of(analysis_vars))
  }
  county
}
