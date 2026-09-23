select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select trip_type
from `nyc-tlc-analytics-500621`.`dev_marts`.`mart_zone_hourly`
where trip_type is null



      
    ) dbt_internal_test