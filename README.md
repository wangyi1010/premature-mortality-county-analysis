# Predictors of Premature Mortality at the County Level in the United States

This repository contains a reproducible RMarkdown analysis of county-level predictors of premature age-adjusted mortality in the United States.

## Contents

- `report.Rmd`: full analysis report and code
- `data/county_health_rankings_2018.xls`: County Health Rankings data
- `data/opioid_prescribing_2016.csv`: CDC county opioid dispensing data

## Research Question

What county-level social, behavioural, healthcare-access, and drug-environment factors are associated with premature age-adjusted mortality in the United States?

## Data Sources

- Robert Wood Johnson Foundation & University of Wisconsin Population Health Institute, County Health Rankings 2018
- U.S. Centers for Disease Control and Prevention, county opioid dispensing rate data, 2016

## Methods

The report uses descriptive statistics, visualisations, correlations, and multivariate linear regression to examine associations between premature mortality and:

- adult smoking
- adult obesity
- uninsured rate
- high-school graduation rate
- child poverty
- opioid dispensing rate

## Reproduce

Open `report.Rmd` in RStudio and knit to PDF.

Required R packages:

- `readxl`
- `readr`
- `dplyr`
- `tidyr`
- `ggplot2`
- `knitr`

