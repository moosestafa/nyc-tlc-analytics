

  create or replace view `nyc-tlc-analytics-500621`.`staging`.`stg_green`
  OPTIONS()
  as SELECT 
VendorID AS vendor_id,
lpep_pickup_datetime AS pickup_datetime,
lpep_dropoff_datetime AS dropoff_datetime,
store_and_fwd_flag AS store_and_fwd_flag,
RatecodeID AS ratecode_id,
PULocationID AS pickup_location_id,
DOLocationID AS dropoff_location_id,
passenger_count AS passenger_count,
trip_distance AS trip_distance,
fare_amount AS fare_amount,
extra AS extra,
mta_tax AS mta_tax,
tip_amount AS tip_amount,
tolls_amount AS tolls_amount,
ehail_fee AS ehail_fee,
improvement_surcharge AS improvement_surcharge,
total_amount AS total_amount,
payment_type AS payment_type,
trip_type AS pickup_type,
congestion_surcharge AS congestion_surcharge,
'green' AS trip_type
from `nyc-tlc-analytics-500621`.`raw`.`green_trips`;

