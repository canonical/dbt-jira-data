{{ config(
  indexes=[
    {'columns': ['state']}
  ]
) }}

select  
    sprint_id,
    name,
    state,
    started_at,
    completed_at
from {{ ref('stg_jira__sprints') }}