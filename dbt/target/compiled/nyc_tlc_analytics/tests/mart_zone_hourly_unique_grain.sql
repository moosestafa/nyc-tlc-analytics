select
    pickup_date,
    pickup_hour,
    trip_type,
    pickup_location_id,
    count(*) as row_count

from `nyc-tlc-analytics-500621`.`dev_marts`.`mart_zone_hourly`

group by
    pickup_date,
    pickup_hour,
    trip_type,
    pickup_location_id

having count(*) > 1