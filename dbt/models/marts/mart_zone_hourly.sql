with trips as (

    select
        pickup_date,
        pickup_hour,
        trip_type,
        pickup_location_id,
        trip_distance,
        trip_duration_minutes,
        total_amount,
        tip_amount
    from {{ ref('fct_trips') }}

    where pickup_date >= '2019-02-01'
      and pickup_hour is not null
      and pickup_location_id is not null

),

locations as (

    select
        location_id,
        borough,
        zone,
        service_zone
    from {{ ref('dim_location') }}

)

select
    t.pickup_date,
    t.pickup_hour,
    t.trip_type,
    t.pickup_location_id,

    l.borough as pickup_borough,
    l.zone as pickup_zone,
    l.service_zone as pickup_service_zone,

    count(*) as trip_count,

    avg(t.trip_distance) as avg_trip_distance,
    avg(t.trip_duration_minutes) as avg_trip_duration_minutes,

    avg(t.total_amount) as avg_total_amount,
    sum(t.total_amount) as total_amount,
    sum(t.tip_amount) as total_tips

from trips t

left join locations l
    on t.pickup_location_id = l.location_id

group by
    t.pickup_date,
    t.pickup_hour,
    t.trip_type,
    t.pickup_location_id,
    l.borough,
    l.zone,
    l.service_zone

    