SELECT

    dispatching_base_num AS dispatching_base_num,

    pickup_datetime AS pickup_datetime,

    CASE
        WHEN DATE(dropOff_datetime) = '1989-01-01' THEN NULL
        ELSE dropOff_datetime
    END AS dropoff_datetime,

   CASE
    WHEN PUlocationID = 0 THEN NULL
    ELSE PUlocationID
END AS pickup_location_id,

    CASE
        WHEN DOlocationID = 0 THEN NULL
        ELSE DOlocationID
    END AS dropoff_location_id,

    SR_Flag AS sr_flag,

    Affiliated_base_number AS affiliated_base_number,

    'fhv' AS trip_type

FROM `nyc-tlc-analytics-500621`.`raw`.`fhv_trips`