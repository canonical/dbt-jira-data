# Usage instructions

## Request access to relevant data catalogs

1. Gather the list of data catalogs to be used as data sources.
2. Choose catalogs to use as a target; generally speaking,
  this should be your team's workspace catalog.
3. Gather the email addresses of the team members who will be developing models in this repository.
4. Open a data access request with the Data Lake team requesting a Trino service account with
  the appropriate permissions. Attach the list of data catalogs and the list of team members.

## Fork this repository

Teams wishing to use dbt should start by forking this repository using the GitHub UI.
Forks should always reside in the `canonical` organization and their names should be
prefixed with `dbt-`.

Precise naming is the team's decision, depending on the granularity of access required.
Examples: `dbt-marketing`, `dbt-growth-engineering`, `dbt-commercial-systems`.

Once forked, clone the forked repository to your local machine and proceed with these instructions.

## Installing dependencies

Install `poetry` and dependencies using the `install` script.

```sh
./install.sh
```

Upon completion, use `poetry run dbt --version` to verify the installation.

## Repository and project structure

For each target data catalog, there should be one directory in the root of the repository
named after that catalog (minus the `_developer` suffix).
For example, if your models are written to `marketing_developer`, the directory must be
called `marketing`.
Wherever you encounter `template` or `TEMPLATE`, replace it with the name of the
data catalog being used (e.g. `marketing` or `MARKETING`, accordingly).

Within each directory, a few files are required:
* `dbt_project.yml` modified with the appropriate value for `profile`.
* `profiles.yml` file.
* `schedules.yml` file.
* `models` directory with the desired `.sql` file(s).

The `template` directory contains a sample dbt project illustrating some of the available
features.
It is recommended to read the [dbt project structure best practices](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview),
which explains the project structure recommended by dbt, which may be used as a starting point.
You may **make a copy** of the `template` directory and rename it to the name of your
data catalog. It is not recommended to modify the `template` directory directly.

### `profiles.yml`
The `profiles.yml` file contains the authentication information for the data platform.
Replace the instances of `template` in the file with the name of the data catalog being used,
using lowercase and uppercase letters accordingly.

This file contains one root key which should match the value of `profile` in `dbt_project.yml`.
Within it, there are two targets under `outputs`: `dev` and `prod`.
* `dev` is used for local development and testing.
* `prod` is used for production deployments. The name of this target should match the value
  of `APP_TARGET` in the environment variables.

### `dbt_project.yml`
The same catalog name should also be used in `dbt_project.yml` where needed.

### `.env`
Keep a single `.env` file in the **root of the repository**, containing the values of
environment variables used in the profiles file.
The authentication method should always be set to `oauth`, and the user and password
values can be ignored.
When running a dbt command, a browser window will open to perform authentication using
Google OAuth.
```
DBT_ENV_***_TRINO_HOST=<hostname> # e.g. trino.ps6.canonical.com
DBT_ENV_***_TRINO_SCHEMA=<schema> # e.g. dbt_dev
```

### References
* [How we structure our dbt projects | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview) 
* [Starburst/Trino setup | dbt Developer Hub](https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup)
* [Environment variables | dbt Developer Hub](https://docs.getdbt.com/docs/build/environment-variables)


## Running dbt

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

To run other dbt commands, or use command line parameters, use:
```sh
poetry run dotenv -f ../.env run dbt [command] [options]
```

### References
* [Run your dbt projects | dbt Developer Hub](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects)

## Scheduling models

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
  Check the [Useful dbt features](#useful-dbt-features) section below for more details.
* The `interval` key is used to specify the schedule in [cron format](https://cron.help/).
  Minute-level granularity is not supported so, if the first field is `*`, the schedule
  will run at a fixed arbitrary minute of the hour.
* The `target` key is used to specify the target environment. 
  One of the values in the `target` list must match the `APP_TARGET` environment variable
  for it to be picked up by the deployed worker.

## Deploying the automated worker

The automated worker can be deployed using a GitHub Action.

### Setting up environment secrets and variables
Before deploying, you must configure the repository secrets and environment variables.
1. On the GitHub web UI, navigate to the Settings tab and then the Environments section.
2. For production deployments, we suggest creating an environment named `prod`.
3. Add secrets and variables as described below.

#### GitHub secrets

| Secret name | Description | Required | Default |
| ----------- | ----------- | -------- | ------- |
| `VAULT_APPROLE_ROLE_ID` | Vault role ID. See [below](#retrieving-vault-credentials) for details. | Yes | |
| `VAULT_APPROLE_SECRET_ID` | Vault secret ID. See [below](#retrieving-vault-credentials) for details. | Yes | |
| `TEMPORAL_AUTH_PROVIDER` | Temporal authentication provider. `google` or `candid`. | No | `google` |
| `TEMPORAL_ENCRYPTION_KEY` | Temporal encryption key, which enables encryption of logs in the Temporal server. [Documentation on how to decrypt logs.](https://github.com/canonical/cs-workflows/tree/main/utils/decryption_server) | No | Logs will not be encrypted. |
| `TEMPORAL_OIDC` | Temporal service account in JSON format. | Yes | |
| `GIT_TOKEN` | A GitHub fine-grained personal access token with read access to the repository. [Documentation on GitHub tokens.](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) This token must have read access to the repository and must be owned by the `canonical` organization. This token needs to be refreshed yearly. | Yes | |
| `DATAHUB_TOKEN` | A DataHub token, retrieved from the DataHub UI. [Documentation on DataHub tokens.](https://datahubproject.io/docs/authentication/personal-access-tokens/) | Yes | |
| `TRINO_OIDC_***` | Trino service account in JSON format, for each dbt project in this repository. Request a service account with the proper permissions from the Data Lake team.  | Yes | |

#### Environment variables

| Environment variable | Description | Required | Default |
| -------------------- | ----------- | -------- | ------- |
| `JUJU_CONTROLLER` | The Juju controller containing the Juju model below. | Yes | |
| `JUJU_MODEL` | The Juju model on which the worker will be deployed. | Yes | |
| `VAULT_SECRET_PATH_ROLE` | Vault secret path pointing to the credentials of the Juju model. See [below](#retrieving-vault-credentials) for details. | Yes | |
| `TEMPORAL_HOST` | Temporal host. Generally `temporal-is.canonical.com`. | Yes | |
| `TEMPORAL_QUEUE` | Temporal queue. | No | `[repo-name]-dbt-queue` |
| `TEMPORAL_NAMESPACE` | Temporal namespace. If necessary, request a Temporal namespace for your team from IS. Generally, it should be called `prod-[team-name]`. | Yes | |
| `SENTRY_DSN` | Sentry DSN. If necessary, request a Sentry instance for your team from IS. | No | Sentry integration is disabled. |
| `SENTRY_ENVIRONMENT` | Sentry environment name. | No | `[app-target]-[repo-name]` |
| `SENTRY_SAMPLE_RATE` | Sentry sample rate. | No | `1.0` |
| `GIT_REPO` | URL of the git repository. Optional, defaults to the current repository. | No | Current repository URL. |
| `GIT_BRANCH` | Repository branch to check out. | No | `main` |
| `GIT_USER` | Git username. | No | `canonical` |
| `DATAHUB_URL` | DataHub GMS URL. Generally `gms.datahub.canonical.com`. | Yes | |
| `APP_TARGET` | Should match the `target` values set in `schedules.yml` and should generally match the GitHub environment name. For example, `prod` for production deployments. | Yes | |
| `DBT_ENV_***_TRINO_HOST` | Trino hostname. Generally `trino.ps6.canonical.com`. | Yes | |

#### Retrieving Vault credentials

If you have access to a Juju model in the bastion, you can retrieve the Vault credentials
using the following commands:

```sh
printenv | grep VAULT_APPROLE_ROLE_ID=
printenv | grep VAULT_APPROLE_SECRET_ID=
printenv | grep VAULT_SECRET_PATH_ROLE=
```

**Please note that these values may grant anyone at Canonical access to your data.**
Use them according to the [Secrets Management Policy](https://docs.google.com/document/d/1dh0T4VMXYAUiUqluwD7CBhhcxOZN8F6FdJHwdumGefs/edit?tab=t.0).
Once stored in GitHub secrets, they cannot be retrieved from GitHub.

#### Multiple dbt projects in the repository
There might be multiple instances of the `TRINO_OIDC_***` secret and the `DBT_ENV_***_TRINO_HOST` environment variable,
for each dbt project present in the repository.
Replace `***` with the `PROJECT_NAME`, e.g. `TRINO_OIDC_MARKETING` and `DBT_ENV_MARKETING_TRINO_HOST`.

#### References
* [GitHub secrets context](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#secrets-context)
* [GitHub variables context](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#vars-context)

### Running the deployment workflow
1. On the GitHub web UI, navigate to the repository and select the `Actions` tab,
where you can find the `Deploy dbt worker` workflow.
2. Click on the `Run workflow` button and select the `prod` environment.
3. After a few minutes, the workflow should be deployed on the selected Juju model.
4. Navigate to the Temporal server, check the Schedules section, and look for the
`dbt-workflow-scheduler` schedule ID.


## Further reading

### Useful dbt features
More details on what is possible when running dbt Core can be found in the
[documentation](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects).
For our purposes, some features are particularly useful:

* We can use `+` and `@` to define which "families" of models to build. This can be used as follows:
  * `[model]` builds only the selected model. This means that if model B depends on model A, the data that is fetched via model A will not be refreshed.
  * `+[model]` builds the models and all its ancestors.
  * `[model]+` builds the model and all its descendants.
  * `+[model]+` builds the model, its ancestors and its descendants.
  * `@[model]` builds the model, its ancestors, its descendants and all ancestors of the descendants.
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
