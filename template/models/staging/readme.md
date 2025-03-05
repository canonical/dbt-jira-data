# Staging models

The staging layer is the foundation of the project.
It is used to bring the raw data from sources into the project, polished and adjusted
according to the needs of the project.

In other words, you can use this to select specific columns from the source, rename them
according to your conventions, and perform simple transformations to make the data easier
to use.

## Guidelines
- Create subdirectories based on the data source (e.g. `salesforce`).
- Model naming: `stg_\[source]__\[entity]s.sql` (use plurals when sensible - e.g. "account**s**").
Examples:
  - `stg_streaming__apple_tv.sql`
  - `stg_streaming__prime_video.sql`
- 1:1 mapping of source tables to staging tables.
- This is the only place where sources are referenced.
- Minimal transformations:
  - Renaming for consistency throughout the project;
  - Type casting;
  - Basic computations (e.g. cents to dollars);
  - Categorizing (using conditional logic to group values into buckets or booleans,
  such as in the case when statements above).
- Avoid joins or aggregations, but they may be necessary in some circumstances.

## Sample query
```sql
with

source as (
    select *
    from
        {{ source('<source>', '<table>') }}
),

staged as (
    select
        a as b,
        x as y
    from
        source
)

select *
from
    staged
```

## Materializations

dbt recommends materializing staging models as views. However, this is not supported
by Trino, so we'll use tables instead.

```yaml
# dbt_project.yml
models:
    <project_name>:
        staging:
            materialized: table
```

## References
* [Staging: Preparing our atomic building blocks | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/2-staging)
