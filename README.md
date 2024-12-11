# dbt Models for Trino

This repository contains dbt models used by Canonical's commercial teams.
dbt is a tool that allows us to specify data transformations directly in our data platform (Trino)
and manages the materialization of tables, documentation and tests.

## Usage

Each team should have their own directory within this repository containing at the very least:
* `dbt_project.yml`
* `schedules.yml` file
* `profiles.yml` file
* `models` directory with a `schema.yml` file and any desired `.sql` file(s).

You may check the `template` directory to see a sample dbt project illustrating some of the available features.

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
