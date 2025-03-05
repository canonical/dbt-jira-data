# Intermediate models

The intermediater layer is where most complex transformations take place.
Isolate such transformations into their own models, and refer to them as needed,
either in other intermediate models or in marts models.

## Guidelines
- Here, subdirectories can be based on business logic groupings.
- Model naming: `int_\[entity]__\[verb]s.sql`. Verbs should represent what's being accomplished in this intermediate model (e.g. `pivoted`, `aggregated_to_user`, `joined`, `fanned_out_by_quantity`, `funnel_created`, etc.).
- Use these models to simplify structures, set the desired level of granularity,
and to isolate complex operations.
- These models should not reference the sources directly, but only
staging models and other intermediate models.

## Materializations

dbt recommends materializing intermediate models ephemerally.
This means they will not be stored in the database, and are rebuilt at each run.

```yaml
# dbt_project.yml
models:
    <project_name>:
        intermediate:
            materialized: ephemeral
```

## References
* [Intermediate: Purpose-built transformation steps | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/3-intermediate)

