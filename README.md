# dbt Models for Trino

This repository contains dbt models used by Canonical's commercial teams.
dbt is a tool that allows us to specify data transformations directly in our data platform (Trino)
and manages the materialization of tables, documentation and tests.

## Usage

### Installing dependencies

`poetry` is used to manage dependencies, itself installed via `pipx`.

```sh
sudo apt install pipx
pipx install poetry
poetry config keyring.enabled false
make install
```

Upon completion, use `poetry run dbt --version` to verify the installation.

### Preparing a dbt project

Each team should have their own directory within this repository containing at the very least:
* `dbt_project.yml` modified with the appropriate value for `profile`.
* `profiles.yml` file.
* `models` directory with a `schema.yml` file and any desired `.sql` file(s).
* `schedules.yml` file.

You may check the `template` directory to see a sample dbt project illustrating some of the available features.

### Authenticating with Trino

When running commands locally, authentication with Trino is done using Oauth. When running a dbt command, a browser window will open to perform authentication.

The value of `<team>-dev` in the `profiles.yml` file should match the profile property of `dbt_project.yml`.
Replace the instances of `<team>` and `<TEAM>` below with the appropriate value – it should match the project directory name.

#### `profiles.yml`
```yaml
<team>: # Used for deployment
  target: ldap
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
      ssl: true
<team>-dev: # Used for local development
  target: oauth
  outputs:
    oauth:
      type: trino
      method: oauth
      host: "{{ env_var('DBT_ENV_<TEAM>_TRINO_HOST') }}"
      catalog: "{{ env_var('DBT_ENV_<TEAM>_CATALOG') }}"
      schema: "{{ env_var('DBT_ENV_<TEAM>_SCHEMA') }}"
      port: 443
```

#### `.env`
Keep a single `.env` in the root of the repository.
```
# The username and password for the Trino instance.
# Variables starting with `DBT_ENV_SECRET` are omitted from logs.
DBT_ENV_<TEAM>_TRINO_USER=<username>
DBT_ENV_SECRET_<TEAM>_TRINO_PASSWORD=<password>
# The URL of the Trino instance.
DBT_ENV_<TEAM>_TRINO_HOST=<hostname> # e.g. trino.ps6.staging.canonical.com
DBT_ENV_<TEAM>_CATALOG=<catalog> # e.g. marketing_developer.
DBT_ENV_<TEAM>_SCHEMA=<schema> # e.g. public for deployment, your_name for development
```

#### References
* [Starburst/Trino setup | dbt Developer Hub](https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup)
* [Environment variables | dbt Developer Hub](https://docs.getdbt.com/docs/build/environment-variables)


### Running dbt

Use `make` to run the desired dbt command.
Available dbt commands:
* `run`: build models in the data platform
* `test`: test models according to rules in YAML files
* `docs`: generate a docs site using descriptions in the YAML files
* `build`: test + run
* `seed`: build seeds according to configuration
* `clean`: clean targets and artifacts

#### References
* [Run your dbt projects | dbt Developer Hub](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects)

### Optional: DataHub ingestion
First, install the DataHub CLI with the dbt extra. Note that the package version must match the deployed version of DataHub. The version can be found via the user menu of the web interface.

```sh
pip install -v "acryl-datahub[dbt]==0.13.2"
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

#### References
* [dbt | DataHub](https://datahubproject.io/docs/generated/ingestion/sources/dbt/)
* [CLI Ingestion | DataHub](https://datahubproject.io/docs/metadata-ingestion/cli-ingestion)

## Further reading

### Useful dbt features
More details on what is possible when running dbt Core can be found in the [documentation](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects). For our purposes, some features are particularly useful:

* We can define which models to build using the --select [model] option. This can be used as follows:
  * `--select [model]` builds only the selected model. This means that if model B depends on model A, the data that is fetched via model A will not be refreshed.
  * `--select +[model]` builds the models and all its ancestors.
  * `--select [model]+` builds the model and all its descendants.
  * `--select +[model]+` builds the model, its ancestors and its descendants.
  * `--select @[model]` builds the model, its ancestors, its descendants and all ancestors of the descendants.
* We can specify multiple versions of a model in the schema files. This way, if a model is undergoing updates, we can build the new version in staging while the previous stable version continues to be used in production.
* We can add data tests and unit tests to our models using dbt’s schema files. It is recommended that models with complex logic have associated unit tests with mock data.

#### References
* [Graph operators | dbt Developer Hub](https://docs.getdbt.com/reference/node-selection/graph-operators)
* [Versions | dbt Developer Hub](https://docs.getdbt.com/reference/resource-properties/versions)
* [Writing custom generic data tests | dbt Developer Hub](https://docs.getdbt.com/best-practices/writing-custom-generic-tests)
* [Unit tests | dbt Developer Hub](https://docs.getdbt.com/docs/build/unit-tests)


### Internal documentation
* [Exploratory notes on dbt](https://docs.google.com/document/d/1MbDLyN6i-QEWughcZZCvRz5MZFrGgXdO6F1yNaFmpBM/edit?tab=t.0)
* [Specification](https://docs.google.com/document/d/1FmXF8PUOJjafB-DIw-dzBVFdUnObXFHJjqi5kHDidjM/edit?tab=t.0)
