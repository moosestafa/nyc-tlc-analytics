

  create or replace view `nyc-tlc-analytics-500621`.`staging`.`stg_fhvhv`
  OPTIONS()
  as SELECT
    hvfhs_license_num AS hvfhs_license_num,
    dispatching_base_num AS dispatching_base_num,
    originating_base_num AS originating_base_num,
    request_datetime AS request_datetime,
    on_scene_datetime AS on_scene_datetime,
    pickup_datetime AS pickup_datetime,
    dropoff_datetime AS dropoff_datetime,
    PULocationID AS pickup_location_id,
    DOLocationID AS dropoff_location_id,
    trip_miles AS trip_distance,
    trip_time AS trip_time,
    base_passenger_fare AS base_passenger_fare,
    tolls AS tolls,
    bcf AS bcf,
    sales_tax AS sales_tax,
    congestion_surcharge AS congestion_surcharge,
    airport_fee AS airport_fee,
    tips AS tip_amount,
    driver_pay AS driver_pay,
    shared_request_flag AS shared_request_flag,
    shared_match_flag AS shared_match_flag,
    access_a_ride_flag AS access_a_ride_flag,
    wav_request_flag AS wav_request_flag,
    wav_match_flag AS wav_match_flag,
    'fhvhv' AS trip_type
FROM `nyc-tlc-analytics-500621`.`raw`.`fhvhv_trips`;

