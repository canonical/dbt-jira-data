# Marts models

This is the final layer in the project, where the final models are built for consumption.
Models in this layer should represent a business-defined entity or concept, which
can then be used to build dashboards, charts, etc.

## Guidelines
- Group subdirectories by area of concern, if needed. You no longer need to worry about
where the data came from, so you can organize it according to who will consume it, e.g.
a dashboard in Superset.
- Name simply by entity, e.g. `accounts.sql` or `opportunities.sql`, with any qualifiers
if relevant.

## Materializations

Marts are the final step in the data pipeline, so they should be materialized as
tables to be consumed by other services.

```yaml
# dbt_project.yml
models:
    <project_name>:
        marts:
            materialized: table
```

## References
* [Marts: Business-defined entities | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/4-marts)
