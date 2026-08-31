
    
    

with dbt_test__target as (

  select hour as unique_field
  from `nyc-tlc-analytics-500621`.`marts`.`dim_time_of_day`
  where hour is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


