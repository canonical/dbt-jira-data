# The name of the python package/project
PY_PACKAGE := canonical_dbt_models

# Paths to venv executables
POETRY := poetry

.PHONY: help
help:  ## Print help about available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install:
	$(POETRY) install --only main --no-root

.PHONY: run
run:
	$(POETRY) run dotenv -f .env run \
		dbt run --project-dir ./$(project) --profiles-dir ./$(project)
