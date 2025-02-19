# Paths to venv executables
POETRY := poetry

.PHONY: help
help:  ## Print help about available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install:
	$(POETRY) install --only main --no-root

.PHONY: clean
clean:
	$(POETRY) run dotenv -f ../.env run dbt clean

.PHONY: run
run:
	$(POETRY) run dotenv -f ../.env run dbt run

.PHONY: test
test:
	$(POETRY) run dotenv -f ../.env run dbt test

.PHONY: build
build:
	$(POETRY) run dotenv -f ../.env run dbt build

.PHONY: seed
seed:
	$(POETRY) run dotenv -f ../.env run dbt seed

.PHONY: docs
docs:
	$(POETRY) run dotenv -f ../.env run dbt docs generate

.PHONY: run-ldap
run-ldap:
	$(POETRY) run dotenv -f ../.env run dbt run --profile "marketing"
