# Template for dbt model repositories

This is a forkable repository for Canonical teams wishing to use dbt for data transformations.
It serves as a template for how dbt repositories should be structured and contains
a sample dbt project.
[dbt](https://docs.getdbt.com) (data build tool) is a tool that allows us to specify data
transformations directly in our data platform (which is federated using Trino) and manages
the materialization of tables, documentation and tests.

## Usage instructions

### Request access to relevant data catalogs

1. Gather the list of data catalogs to be used as data sources.
2. Choose catalogs to use as a target; generally speaking,
  this should be your team's workspace catalog.
3. Gather the email addresses of the team members who will be developing models in this repository.
4. Open a data access request with the Data Governance team requesting a Trino user with
  the appropriate permissions. Attach the list of data catalogs and the list of team members.

### Fork this repository

Teams wishing to use dbt should start by forking this repository using the GitHub UI.
Forks should always reside in the `canonical` organization and their names should be
prefixed with `dbt-`.

Precise naming is the team's decision, depending on the granularity of access required.
Examples: `dbt-marketing`, `dbt-growth-engineering`, `dbt-commercial-systems`.

Once forked, clone the forked repository to your local machine and proceed with these instructions.

### Installing dependencies

Install `poetry` and dependencies using the `install` script.

```sh
./install.sh
```

Upon completion, use `poetry run dbt --version` to verify the installation.

### Repository and project structure

For each target data catalog, there should be one directory in the root of the repository
named after that catalog (minus the `_developer` suffix).
For example, if your models are written to `marketing_developer`, the directory must be
called `marketing`.

Within each directory, a few files are required:
* `dbt_project.yml` modified with the appropriate value for `profile`.
* `profiles.yml` file.
* `schedules.yml` file.
* `models` directory with the desired `.sql` file(s).

The `template` directory contains a sample dbt project illustrating some of the available
features.
It is recommended to read the link below, which explains the project structure recommended
by dbt, which may be used as a starting point.

#### References
* [How we structure our dbt projects | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview) 

### Authenticating with Trino

#### `profiles.yml`
The `profiles.yml` file contains the authentication information for the data platform.
Replace the instances of `<catalog>` below with the name of the data catalog being used.

```yaml
<catalog>:
  target: dev
  outputs:
    dev:
      type: trino
      method: "{{ env_var('DBT_ENV_AUTH_METHOD') }}"
      user: "{{ env_var('DBT_ENV_TRINO_USER') }}"
      password: "{{ env_var('DBT_ENV_SECRET_TRINO_PASSWORD') }}"
      host: "{{ env_var('DBT_ENV_TRINO_HOST') }}"
      catalog: "{{ env_var('DBT_ENV_CATALOG') }}"
      schema: "{{ env_var('DBT_ENV_SCHEMA') }}"
      port: 443
      ssl: true
```

#### `dbt_project.yml`
The same catalog name should also be used in `dbt_project.yml`.
```yaml
name: <catalog>
...
profile: <catalog>
...
models:
  <catalog>:
    staging:
      +materialized: table
    intermediate:
      +materialized: ephemeral
    marts:
      +materialized: table
```

#### `.env`
Keep a single `.env` file in the directory, containing the values of
environment variables used in the profiles file.
The authentication method should always be set to `oauth`, and the user and password
values can be ignored.
When running a dbt command, a browser window will open to perform authentication using
Google OAuth.
```
DBT_ENV_AUTH_METHOD=oauth
DBT_ENV_TRINO_HOST=<hostname> # e.g. trino.ps6.canonical.com
DBT_ENV_CATALOG=<catalog>_developer # e.g. marketing_developer
DBT_ENV_SCHEMA=<schema> # e.g. dbt_dev
```

#### References
* [Starburst/Trino setup | dbt Developer Hub](https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup)
* [Environment variables | dbt Developer Hub](https://docs.getdbt.com/docs/build/environment-variables)


### Running dbt

Copy the `Makefile` from the `template` directory to your catalog directory.
Then, you may use `make` to run the desired dbt command and other useful commands.

Available commands:
* `make run`: build models in the data platform
* `make test`: test models according to rules in YAML files
* `make docs`: generate a docs site using descriptions in the YAML files
* `make build`: test + run
* `make seed`: build seeds according to configuration
* `make clean`: clean targets and artifacts
* `make lint`: lint YAML and SQL files
* `make fmt`: format SQL files

#### References
* [Run your dbt projects | dbt Developer Hub](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects)

### Scheduling models

The deployed worker uses information from the `schedules.yml` file to determine when to
run models.
It follows this format:
```yaml
schedules:
  - name: my_model__daily
    models: 
      - +model1 
      - model2
    interval: "0 17 * * *" # e.g. daily at 17:00
    target:
      - dev
```

* The `name` key is used to identify the schedule. It should be unique.
* The `models` key is used to specify a list of models to be built. 
  Check the [Useful dbt features](https://github.com/canonical/dbt-template#useful-dbt-features)
section below for more details.
* The `interval` key is used to specify the schedule in [cron format](https://cron.help/).
  Minute-level granularity is not supported, so the first field should be `0`.
* The `target` key is used to specify the target environment. 
  If `prod` is not specified, the schedule will be ignored by the deployed worker.

## Further reading

### Useful dbt features
More details on what is possible when running dbt Core can be found in the
[documentation](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects).
For our purposes, some features are particularly useful:

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
