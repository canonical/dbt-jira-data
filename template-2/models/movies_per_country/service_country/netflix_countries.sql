with countries as (
    select * from {{ ref('countries') }}
),

netflix_countries as (
    select
        title,
        imdbId,
        availableCountries,
        country_code
    from {{ source('streaming', 'netflix') }}
    cross join countries
    where type = 'movie'
    and {{ dbt.position("country_code", "availableCountries") }} > 0
)

select * from netflix_countries

