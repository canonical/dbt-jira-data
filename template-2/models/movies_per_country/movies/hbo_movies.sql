with hbo_countries as (
    select * from {{ ref('hbo_countries') }}
),

hbo_movies as (
    select
        imdbId as id,
        "hbo_max" as source,
        title,
        country_code as country
    from hbo_countries
)

select * from hbo_movies
