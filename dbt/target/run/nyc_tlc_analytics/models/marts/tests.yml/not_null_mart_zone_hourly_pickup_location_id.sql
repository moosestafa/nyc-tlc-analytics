select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select pickup_location_id
from `nyc-tlc-analytics-500621`.`dev_marts`.`mart_zone_hourly`
where pickup_location_id is null



      
    ) dbt_internal_test