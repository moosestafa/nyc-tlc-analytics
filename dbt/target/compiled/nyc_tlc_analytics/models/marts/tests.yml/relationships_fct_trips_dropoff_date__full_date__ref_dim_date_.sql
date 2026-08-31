
    
    

with child as (
    select dropoff_date as from_field
    from `nyc-tlc-analytics-500621`.`marts`.`fct_trips`
    where dropoff_date is not null
),

parent as (
    select full_date as to_field
    from `nyc-tlc-analytics-500621`.`marts`.`dim_date`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


