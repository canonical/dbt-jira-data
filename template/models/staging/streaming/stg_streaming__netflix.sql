with

source as (
    select * from {{ source('streaming', 'netflix') }}
),

staged as (
    select
        imdbid as id,
        'netflix' as source,
        title,
        availablecountries as available_countries,
        type
    from source
)

select * from staged
