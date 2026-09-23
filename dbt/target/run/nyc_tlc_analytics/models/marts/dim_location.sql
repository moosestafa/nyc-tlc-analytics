
  
    

    create or replace table `nyc-tlc-analytics-500621`.`dev_marts`.`dim_location`
      
    
    

    OPTIONS()
    as (
      SELECT LocationID as location_id, Borough as borough, Zone as zone, service_zone
from `nyc-tlc-analytics-500621`.`dev_staging`.`taxi_zone_lookup`
    );
  