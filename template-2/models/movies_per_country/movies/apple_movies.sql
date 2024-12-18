with countries as (
    select * from {{ ref('countries') }}
),

apple_countries as (
    select
        title,
        imdbId,
        availableCountries,
        country_code
    from {{ source('streaming', 'apple_tv') }}
    cross join countries
    where type = 'movie'
    and {{ dbt.position("country_code", "availableCountries") }} > 0
),

apple_movies as (
    select
        imdbId as id,
        "apple_tv" as source,
        title,
        country_code as country
    from apple_countries
)

select * from apple_movies
