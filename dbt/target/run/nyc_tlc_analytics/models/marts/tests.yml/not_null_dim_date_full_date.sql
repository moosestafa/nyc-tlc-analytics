select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select full_date
from `nyc-tlc-analytics-500621`.`marts`.`dim_date`
where full_date is null



      
    ) dbt_internal_test