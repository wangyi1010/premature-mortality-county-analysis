# Data

Raw inputs live in `data/raw/`. Both are publicly released by their providers and
are included here only to make the analysis self-contained and reproducible. All
rights remain with the original providers; the files are used for non-commercial
research and educational purposes.

## `raw/county_health_rankings_2018.xls`

- Provider: Robert Wood Johnson Foundation & University of Wisconsin Population
  Health Institute — County Health Rankings & Roadmaps.
- Year: 2018 release.
- Source: <https://www.countyhealthrankings.org/health-data> (national data downloads).
- Used sheets/columns:
  - Sheet 6 ("Age-Adjusted Mortality") — outcome: premature age-adjusted mortality
    per 100,000.
  - Sheet 4 ("Ranked Measure Data") — predictors: adult smoking, adult obesity,
    uninsured %, high-school graduation rate, children in poverty %.

## `raw/opioid_prescribing_2016.csv`

- Provider: U.S. Centers for Disease Control and Prevention.
- Year: 2016.
- Source: <https://www.cdc.gov/drugoverdose/rxrate-maps/> (U.S. county opioid
  dispensing rate maps / underlying data).
- Used columns: county FIPS code and the 2016 opioid dispensing rate per 100 persons.

## Joining

Both datasets are keyed on the 5-digit county FIPS code. `R/data.R` merges them,
drops state/national aggregate rows, coerces to numeric, and (for modelling)
restricts to complete cases — 2,611 counties. See `R/data.R` for the exact logic.
