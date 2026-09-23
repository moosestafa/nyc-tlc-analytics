select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select pickup_hour
from `nyc-tlc-analytics-500621`.`dev_marts`.`mart_zone_hourly`
where pickup_hour is null



      
    ) dbt_internal_test