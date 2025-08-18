with histories as (
  select * from {{ ref('stg_jira__issue_status_histories') }}
),

items as (
  select
    issue_id,
    issue_key,
    i->>'created' as changed_at,
    i->>'field' as field,
    i->>'fromString' as from_status,
    i->>'toString'  as to_status
  from histories
  cross join lateral jsonb_array_elements(items_json) as i
),

status_changes as (
  select
    issue_id,
    issue_key,
    changed_at,
    from_status,
    to_status
  from items
  where field = 'status'
    and (coalesce(from_status, '') <> '' or coalesce(to_status, '') <> '')
    and (from_status is distinct from to_status)
)

select * from status_changes