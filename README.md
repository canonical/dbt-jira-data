# dbt Models for Trino

This repository contains dbt models used by Canonical's commercial teams.
dbt is a tool that allows us to specify data transformations directly in our data platform (Trino)
and manages the materialization of tables, documentation and tests.

## Usage

### Installing dbt Core

It is recommended to install dbt using a virtual environment and pip.
```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install dbt-core dbt-trino
```
More info: [Install with pip](https://docs.getdbt.com/docs/core/pip-install)

Also install the dotenv package for loading environment variables:
```sh
pip install python-dotenv
```

### Preparing a dbt project

Each team should have their own directory within this repository containing at the very least:
* `dbt_project.yml`
* `profiles.yml` file
* `models` directory with a `schema.yml` file and any desired `.sql` file(s).
* `schedules.yml` file (not needed when running locally)

You may check the `template` directory to see a sample dbt project illustrating some of the available features.

### Authenticating with Trino

Authentication with Trino can be done using LDAP (username+password). Acquire a username/password pair with the proper authorizations from the Data Federation team.

The value of `your_team_name` in the `profiles.yml` file should match the profile property of `dbt_project.yml`. Replace the instances of `<TEAM>` below with the appropriate value.

#### `profiles.yml`
```yaml
your_team_name:
    target: dev
    outputs:
        dev:
            type: trino
            method: ldap
            user: "{{ env_var('DBT_ENV_<TEAM>_TRINO_USER') }}"
            password: "{{ env_var('DBT_ENV_SECRET_<TEAM>_TRINO_PASSWORD') }}"
            host: "{{ env_var('DBT_ENV_<TEAM>_TRINO_HOST') }}"
            catalog: "{{ env_var('DBT_ENV_<TEAM>_CATALOG') }}"
            schema: "{{ env_var('DBT_ENV_<TEAM>_SCHEMA') }}"
            port: 443
```

#### `.env`
```
# The username and password for the Trino instance.
# Variables starting with `DBT_ENV_SECRET` are omitted from logs.
DBT_ENV_<TEAM>_TRINO_USER=<username>
DBT_ENV_SECRET_<TEAM>_TRINO_PASSWORD=<password>
# The URL of the Trino instance.
DBT_ENV_<TEAM>_TRINO_HOST=<hostname> # e.g. trino.ps6.staging.canonical.com
DBT_ENV_<TEAM>_CATALOG=<catalog> # e.g. marketing_developer.
DBT_ENV_<TEAM>_SCHEMA=<schema> # e.g. public
```

### Running dbt

Use `dotenv` to load the environment variables, then run the desired dbt command:
```sh
dotenv -f .env run dbt run
```
Available dbt commands:
* `dbt run`: build models in the data platform
* `dbt test`: test models according to rules in YAML files
* `dbt docs generate`: generate a docs site using descriptions in the YAML files
* `dbt docs serve`: serve the previously generated docs in a web server
* `dbt build`: test + run
* `dbt seed`: build seeds according to configuration

### Optional: DataHub ingestion
First, install the DataHub CLI with the dbt extra. Note that the package version must match the deployed version of DataHub. The version can be found via the user menu of the web interface.

```sh
python3 -m pip install -v "acryl-datahub[dbt]==0.13.2"
```

Then, prepare the recipe file and environment variables:

#### `recipe.yml`
```yaml
source:
  type: dbt
  config:
    manifest_path: "${DBT_PROJECT_ROOT}/target/manifest.json"
    catalog_path: "${DBT_PROJECT_ROOT}/target/catalog.json"
    run_results_paths:
      - "${DBT_PROJECT_ROOT}/target/run_results.json"
    target_platform: trino

sink:
  type: datahub-rest
  config:
    server: ${DATAHUB_URL}
    token: ${DATAHUB_TOKEN}
```

#### `.env`
```
DBT_PROJECT_ROOT=<path to dbt project>
DATAHUB_URL=<datahub GMS URL> # e.g. https://gms.datahub.ps6.stg.canonical.com
DATAHUB_TOKEN=<datahub GMS token> # acquired from user settings of web interface
```

Finally, run the data ingestion:
```sh
dotenv -f .env datahub ingest -c recipe.yml
```

## Further reading

### Useful dbt features
More details on what is possible when running dbt Core can be found in the [documentation](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects). For our purposes, some features are particularly useful:

* We can define which models to build using the --select [model] option. This can be used as follows.
[Reference](https://docs.getdbt.com/reference/node-selection/graph-operators)
  * --select [model] builds only the selected model. This means that if model B depends on model A, the data that is fetched via model A will not be refreshed.
  * --select +[model] builds the models and all its ancestors.
  * --select [model]+ builds the model and all its descendants.
  * --select +[model]+ builds the model, its ancestors and its descendants.
  * --select @[model] builds the model, its ancestors, its descendants and all ancestors of the descendants.
* We can specify multiple versions of a model in the schema files. This way, if a model is undergoing updates, we can build the new version in staging while the previous stable version continues to be used in production. [Reference](https://docs.getdbt.com/reference/resource-properties/versions)
* We can add [data tests](https://docs.getdbt.com/best-practices/writing-custom-generic-tests) and [unit tests](https://docs.getdbt.com/docs/build/unit-tests) to our models using dbt’s schema files. It is recommended that models with complex logic have associated unit tests with mock data.

### Internal documentation
[dbt notes](https://docs.google.com/document/d/1MbDLyN6i-QEWughcZZCvRz5MZFrGgXdO6F1yNaFmpBM/edit?tab=t.0)
[Specification](https://docs.google.com/document/d/1FmXF8PUOJjafB-DIw-dzBVFdUnObXFHJjqi5kHDidjM/edit?tab=t.0)
