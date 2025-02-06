The staging layer is where our journey begins. This is the foundation of our project, where we bring all the individual components we're going to use to build our more complex and useful models into the project.

We'll use an analogy for working with dbt throughout this guide: thinking modularly in terms of atoms, molecules, and more complex outputs like proteins or cells (we apologize in advance to any chemists or biologists for our inevitable overstretching of this metaphor). Within that framework, if our source system data is a soup of raw energy and quarks, then you can think of the staging layer as condensing and refining this material into the individual atoms we’ll later build more intricate and useful structures with.

- subdirectories based on the source system (e.g. "salesforce")
- naming: stg_\[source]__\[entity]s.sql (use plurals - e.g. "lead**s**")
- 1:1 mapping of source tables to staging tables
- this is the only place where sources are referenced
- minimal transformations:
  - Renaming
  - Type casting
  - Basic computations (e.g. cents to dollars)
  - Categorizing (using conditional logic to group values into buckets or booleans, such as in the case when statements above)
- no joins or aggregations

Structures of queries:

```
with source as (...),
staged as (...)
select * from staged
```