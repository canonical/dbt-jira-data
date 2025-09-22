with issues_base as (
    select
        issue_id,
        issue_key,
        from_iso8601_timestamp(json_extract_scalar(fields_json, '$.created')) as created_at
    from {{ ref('stg_jira__issues') }}
),

histories as (
    select
        issue_id,
        issue_key,
        changelog_json
    from {{ ref('stg_jira__issues') }}
),

items as (
    select
        h.issue_id,
        h.issue_key,
        from_iso8601_timestamp(json_extract_scalar(hh.hist, '$.created')) as changed_at,
        json_extract_scalar(ii.itm, '$.field') as field,
        json_extract_scalar(ii.itm, '$.fromString') as from_string,
        json_extract_scalar(ii.itm, '$.toString') as to_string,
        json_extract_scalar(ii.itm, '$.from') as from_id,
        json_extract_scalar(ii.itm, '$.to') as to_id
    from histories as h
    cross join
        unnest(
            cast(json_extract(h.changelog_json, '$.histories') as array(json))
        ) as hh (hist)
    cross join unnest(
        coalesce(
            cast(json_extract(hh.hist, '$.items') as array(json)),
            cast(array[] as array(json))
        )
    ) as ii (itm)
),

sprint_changes as (
    select
        issue_id,
        issue_key,
        changed_at,
        from_string,
        to_string,
        from_id,
        to_id
    from items
    where lower(field) = 'sprint'
),

first_change as (
    select
        t.issue_id,
        t.issue_key,
        t.changed_at,
        t.from_string,
        t.to_string,
        t.from_id,
        t.to_id
    from (
        select
            sc.*,
            row_number() over (
                partition by sc.issue_id
                order by sc.changed_at asc
            ) as rn
        from sprint_changes as sc
    ) as t
    where t.rn = 1
),

initial_from_history as (
    select
        ib.issue_id,
        ib.issue_key,
        ib.created_at as changed_at,
        cast(null as varchar) as from_string,
        fc.to_string,
        cast(null as varchar) as from_id,
        fc.to_id
    from issues_base as ib
    inner join first_change as fc
        on ib.issue_id = fc.issue_id
)

select * from initial_from_history
union all
select * from sprint_changes
