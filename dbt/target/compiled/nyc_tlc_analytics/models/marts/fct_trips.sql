with yellow as (

    select
        trip_type,
        pickup_datetime,
        dropoff_datetime,
        date(pickup_datetime) as pickup_date,
        date(dropoff_datetime) as dropoff_date,
        extract(hour from pickup_datetime) as pickup_hour,
        extract(hour from dropoff_datetime) as dropoff_hour,
        pickup_location_id,
        dropoff_location_id,
        trip_distance,
        timestamp_diff(
            dropoff_datetime,
            pickup_datetime,
            second
        ) / 60.0 as trip_duration_minutes,
        passenger_count,
        fare_amount as base_fare_amount,
        tip_amount,
        tolls_amount,
        total_amount,
        payment_type
    from `nyc-tlc-analytics-500621`.`staging`.`stg_yellow`

),

green as (

    select
        trip_type,
        pickup_datetime,
        dropoff_datetime,
        date(pickup_datetime) as pickup_date,
        date(dropoff_datetime) as dropoff_date,
        extract(hour from pickup_datetime) as pickup_hour,
        extract(hour from dropoff_datetime) as dropoff_hour,
        pickup_location_id,
        dropoff_location_id,
        trip_distance,
        timestamp_diff(
            dropoff_datetime,
            pickup_datetime,
            second
        ) / 60.0 as trip_duration_minutes,
        passenger_count,
        fare_amount as base_fare_amount,
        tip_amount,
        tolls_amount,
        total_amount,
        payment_type
    from `nyc-tlc-analytics-500621`.`staging`.`stg_green`

),

fhvhv as (

    select
        trip_type,
        pickup_datetime,
        dropoff_datetime,

        date(pickup_datetime) as pickup_date,
        date(dropoff_datetime) as dropoff_date,

        extract(hour from pickup_datetime) as pickup_hour,
        extract(hour from dropoff_datetime) as dropoff_hour,

        pickup_location_id,
        dropoff_location_id,

        trip_distance,

        timestamp_diff(
            dropoff_datetime,
            pickup_datetime,
            second
        ) / 60.0 as trip_duration_minutes,

        cast(null as int64) as passenger_count,

        base_passenger_fare as base_fare_amount,
        tip_amount,
        tolls as tolls_amount,

        cast(null as float64) as total_amount,
        cast(null as int64) as payment_type

    from `nyc-tlc-analytics-500621`.`staging`.`stg_fhvhv`

),
fhv as (

    select
        trip_type,
        pickup_datetime,
        dropoff_datetime,

        date(pickup_datetime) as pickup_date,
        date(dropoff_datetime) as dropoff_date,

        extract(hour from pickup_datetime) as pickup_hour,
        extract(hour from dropoff_datetime) as dropoff_hour,

        pickup_location_id,
        dropoff_location_id,

        cast(null as float64) as trip_distance,

        timestamp_diff(
            dropoff_datetime,
            pickup_datetime,
            second
        ) / 60.0 as trip_duration_minutes,

        cast(null as int64) as passenger_count,

        cast(null as float64) as base_fare_amount,
        cast(null as float64) as tip_amount,
        cast(null as float64) as tolls_amount,
        cast(null as float64) as total_amount,

        cast(null as int64) as payment_type

    from `nyc-tlc-analytics-500621`.`staging`.`stg_fhv`

)
select * from yellow
union all
select * from green
union all
select * from fhvhv
union all 
select * from fhv