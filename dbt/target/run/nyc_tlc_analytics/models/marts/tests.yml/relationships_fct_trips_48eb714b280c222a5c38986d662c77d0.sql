select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with child as (
    select dropoff_hour as from_field
    from `nyc-tlc-analytics-500621`.`marts`.`fct_trips`
    where dropoff_hour is not null
),

parent as (
    select hour as to_field
    from `nyc-tlc-analytics-500621`.`marts`.`dim_time_of_day`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



      
    ) dbt_internal_test