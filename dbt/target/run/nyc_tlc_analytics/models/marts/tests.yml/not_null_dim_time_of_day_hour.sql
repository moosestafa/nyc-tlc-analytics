select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select hour
from `nyc-tlc-analytics-500621`.`dev_marts`.`dim_time_of_day`
where hour is null



      
    ) dbt_internal_test