with countries as (
    select * from {{ ref('countries') }}
),

movies as (
    select * 
    from {{ source('streaming', 'prime_video') }}
    where type = 'movie'
),

amazon_countries as (
    select
        title,
        imdbId,
        availableCountries,
        country_code
    from movies
    cross join countries
    where {{ dbt.position("country_code", "availableCountries") }} > 0
)

select * from amazon_countries
