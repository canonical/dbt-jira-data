{{ config(
  alias='int_jira__issues_flat',
  materialized='incremental',
  unique_key='issue_id',
  on_schema_change='sync_all_columns'
) }}

with base as (
  select * from {{ ref('stg_jira__issues') }}
),

-- Extract and cast in one place
flattened as (
  select
      issue_id,
      issue_key,
      project_key,

      (fields_json->'issuetype'->>'name')                          as issue_type,
      (fields_json->>'summary')                                     as summary,
      (fields_json->'priority'->>'name')                            as priority,
      (fields_json->'reporter'->>'displayName')                     as reporter,
      (fields_json->'assignee'->>'displayName')                     as assignee,
      (fields_json->'status'->>'name')                              as status,
      (fields_json->>'created')::timestamptz                        as created_at,
      nullif(fields_json->>'resolutiondate','')::timestamptz        as resolved_at,
      nullif(fields_json->>'customfield_10024','')::numeric         as story_points,
      (fields_json->'project'->>'name')                             as project,

      -- keep raw timestamps too (from top-level) just in case
      created                                                         as created_raw,
      updated                                                         as updated_raw
  from base
)

select * from flattened
