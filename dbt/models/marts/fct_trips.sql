with date_bounds as (

    select
        min(full_date) as min_date,
        max(full_date) as max_date
    from {{ ref('dim_date') }}

),

yellow as (

    select
        trip_type,
        pickup_datetime,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then dropoff_datetime
            else null
        end as dropoff_datetime,

        date(pickup_datetime) as pickup_date,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then date(dropoff_datetime)
            else null
        end as dropoff_date,

        extract(hour from pickup_datetime) as pickup_hour,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then extract(hour from dropoff_datetime)
            else null
        end as dropoff_hour,

        pickup_location_id,
        dropoff_location_id,
        trip_distance,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then timestamp_diff(
                dropoff_datetime,
                pickup_datetime,
                second
            ) / 60.0
            else null
        end as trip_duration_minutes,

        passenger_count,
        fare_amount as base_fare_amount,
        tip_amount,
        tolls_amount,
        total_amount,
        payment_type

    from {{ ref('stg_yellow') }}
    cross join date_bounds d

    where date(pickup_datetime) between d.min_date and d.max_date

),

green as (

    select
        trip_type,
        pickup_datetime,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then dropoff_datetime
            else null
        end as dropoff_datetime,

        date(pickup_datetime) as pickup_date,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then date(dropoff_datetime)
            else null
        end as dropoff_date,

        extract(hour from pickup_datetime) as pickup_hour,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then extract(hour from dropoff_datetime)
            else null
        end as dropoff_hour,

        pickup_location_id,
        dropoff_location_id,
        trip_distance,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then timestamp_diff(
                dropoff_datetime,
                pickup_datetime,
                second
            ) / 60.0
            else null
        end as trip_duration_minutes,

        passenger_count,
        fare_amount as base_fare_amount,
        tip_amount,
        tolls_amount,
        total_amount,
        payment_type

    from {{ ref('stg_green') }}
    cross join date_bounds d

    where date(pickup_datetime) between d.min_date and d.max_date

),

fhvhv as (

    select
        trip_type,
        pickup_datetime,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then dropoff_datetime
            else null
        end as dropoff_datetime,

        date(pickup_datetime) as pickup_date,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then date(dropoff_datetime)
            else null
        end as dropoff_date,

        extract(hour from pickup_datetime) as pickup_hour,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then extract(hour from dropoff_datetime)
            else null
        end as dropoff_hour,

        pickup_location_id,
        dropoff_location_id,
        trip_distance,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then timestamp_diff(
                dropoff_datetime,
                pickup_datetime,
                second
            ) / 60.0
            else null
        end as trip_duration_minutes,

        cast(null as int64) as passenger_count,

        base_passenger_fare as base_fare_amount,
        tip_amount,
        tolls as tolls_amount,

        cast(null as float64) as total_amount,
        cast(null as int64) as payment_type

    from {{ ref('stg_fhvhv') }}
    cross join date_bounds d

    where date(pickup_datetime) between d.min_date and d.max_date

),

fhv as (

    select
        trip_type,
        pickup_datetime,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then dropoff_datetime
            else null
        end as dropoff_datetime,

        date(pickup_datetime) as pickup_date,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then date(dropoff_datetime)
            else null
        end as dropoff_date,

        extract(hour from pickup_datetime) as pickup_hour,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then extract(hour from dropoff_datetime)
            else null
        end as dropoff_hour,

        pickup_location_id,
        dropoff_location_id,

        cast(null as float64) as trip_distance,

        case
            when date(dropoff_datetime) between d.min_date and d.max_date
            then timestamp_diff(
                dropoff_datetime,
                pickup_datetime,
                second
            ) / 60.0
            else null
        end as trip_duration_minutes,

        cast(null as int64) as passenger_count,

        cast(null as float64) as base_fare_amount,
        cast(null as float64) as tip_amount,
        cast(null as float64) as tolls_amount,
        cast(null as float64) as total_amount,

        cast(null as int64) as payment_type

    from {{ ref('stg_fhv') }}
    cross join date_bounds d

    where date(pickup_datetime) between d.min_date and d.max_date

)

select * from yellow

union all

select * from green

union all

select * from fhvhv

union all

select * from fhv