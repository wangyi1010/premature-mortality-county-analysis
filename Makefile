# Convenience targets. Run `make help` to list them.

.PHONY: all deps analysis report test clean help

all: analysis report ## Run the pipeline and render the report

deps: ## Restore pinned R packages from renv.lock
	Rscript -e 'renv::restore(prompt = FALSE)'

analysis: ## Run the analysis pipeline (figures + model summary)
	Rscript scripts/run_analysis.R

report: ## Render report.Rmd to report.pdf
	Rscript -e 'rmarkdown::render("report.Rmd")'

test: ## Run the testthat suite
	Rscript tests/testthat.R

clean: ## Remove generated outputs and LaTeX cruft
	rm -f outputs/figures/*.png outputs/model_summary.txt
	rm -f report.log report.aux report.out report.toc

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
