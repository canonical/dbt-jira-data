with

source as (
    select * from {{ source('jira', 'issues') }}
),

staged as (
    select
        CAST(id AS BIGINT) as issue_id,
        key as issue_key,
        changelog as changelog_json,
        "projectKey" as project_key
    from source
)

select *
from staged
where project_key in (
    'KE','SNAPDENG','KRNS','MIRENG','ROBENG',
    'C3','ZAP','CHECKBOX','RTW','LM','CERTTF',
    'IQA','SQT','IENG','AC','WD',
    'TORENG','DPUENG','RTOS','JUJU','KU','MAASENG'
)