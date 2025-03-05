with

netflix as (
    select *
    from {{ ref('stg_streaming__netflix') }}
),

netflix_movies as (
    select *
    from netflix
    where type = 'movie'
)

select *
from
    netflix_movies
