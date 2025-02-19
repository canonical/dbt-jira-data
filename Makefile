#The name of the python package/project
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

.PHONY: actions
actions:
	gh act \
		--var-file .env \
		--secret-file .env \
		-P self-hosted=-self-hosted \
		pull_request

.PHONY: lint
lint:
	$(POETRY) run yamllint \
		-c .github/config/yaml_rules.yaml .
	$(POETRY) run sqlfluff lint \
		--config .github/config/sql_rules.toml \
		--dialect trino .

.PHONY: fmt
fmt:
	$(POETRY) run sqlfluff format \
		--config .github/config/sql_rules.toml \
		--dialect trino .
