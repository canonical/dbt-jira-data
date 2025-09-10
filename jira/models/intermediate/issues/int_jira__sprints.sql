with base as (
  select
      sprint_id,
      name,
      state,
      started_at,
      completed_at
  from {{ ref('stg_jira__sprints') }}
),

normalized as (
  select
      sprint_id,
      name as original_name,
      -- normalized canonical name: YYYY#NN (left-pad sprint number to 2 digits)
      CASE
        WHEN regexp_like(
          name,
          '(?i).*(?:^|[^0-9])(20[0-9]{2})[ \t]*#[ \t]*([0-9]{1,2})(?:[^0-9]|$).*'
        ) THEN concat(
          regexp_extract(name, '(?i).*(?:^|[^0-9])(20[0-9]{2})[ \t]*#[ \t]*([0-9]{1,2})(?:[^0-9]|$).*', 1),
          '#',
          lpad(regexp_extract(name, '(?i).*(?:^|[^0-9])(20[0-9]{2})[ \t]*#[ \t]*([0-9]{1,2})(?:[^0-9]|$).*', 2), 2, '0')
        )
        ELSE 'ERROR'
      END AS name,
      state,
      started_at,
      completed_at
  from base
)

select * from normalized