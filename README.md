# Predictors of Premature Mortality at the County Level in the United States

A reproducible RMarkdown analysis of the social, behavioural, healthcare-access, and
drug-environment factors associated with **premature age-adjusted mortality** (deaths
before age 75) across US counties.

## Headline finding

Across **2,611 counties**, a six-predictor OLS model explains **73%** of the variation in
premature age-adjusted mortality (R² = 0.732, adjusted R² = 0.731). **Child poverty is
the strongest predictor**, followed by adult smoking and the opioid dispensing rate.
High-school graduation rate — expected to protect against mortality — loses almost all of
its association once socioeconomic and behavioural factors are held constant, a textbook
case of confounding.

### Standardised effect sizes

Coefficients are from the model fit on standardised (z-scored) variables, so they are
directly comparable. Higher magnitude = stronger partial association with premature
mortality.

| Predictor | Std. coefficient | Direction |
|---|---:|---|
| Children in poverty (%) | **0.40** | ↑ mortality |
| Adult smoking (%) | 0.27 | ↑ mortality |
| Opioid dispensing rate, 2016 | 0.21 | ↑ mortality |
| Adult obesity (%) | 0.16 | ↑ mortality |
| Uninsured (%) | 0.11 | ↑ mortality |
| High-school graduation rate (%) | 0.03 | negligible |

## Research question

What county-level social, behavioural, healthcare-access, and drug-environment factors
are associated with premature age-adjusted mortality in the United States?

## Methods

Descriptive statistics, visualisations, pairwise correlations, and a multivariate OLS
regression with variance-inflation-factor checks for multicollinearity. The graduation-rate
predictor is examined before and after controls to make the confounding explicit. The
report is careful to frame results as **county-level (ecological) associations**, not
individual-level causal effects.

## Data sources

| Dataset | Provider | Source |
|---|---|---|
| County Health Rankings 2018 (outcomes + predictors) | Robert Wood Johnson Foundation & University of Wisconsin Population Health Institute | <https://www.countyhealthrankings.org/> |
| County opioid dispensing rate, 2016 | U.S. Centers for Disease Control and Prevention | <https://www.cdc.gov/drugoverdose/rxrate-maps/> |

Both datasets are publicly released by their providers. Copies are included here under
`data/` only to make the analysis self-contained and reproducible; all rights remain with
the original providers, and the data are used here for non-commercial research and
educational purposes.

## Repository layout

```
report.Rmd    full analysis: code, tables, figures, and write-up
report.pdf    knitted output
data/         input datasets (see attribution above)
```

## Reproduce

Open `report.Rmd` in RStudio and knit to PDF, or from the command line:

```r
rmarkdown::render("report.Rmd")
```

Required R packages: `readxl`, `readr`, `dplyr`, `tidyr`, `ggplot2`, `knitr`.
A LaTeX installation (e.g. TinyTeX) is needed for PDF output.

## License

Code and write-up are released under the [MIT License](LICENSE). The bundled datasets are
the property of their respective providers (see attribution above) and are not covered by
that license.
