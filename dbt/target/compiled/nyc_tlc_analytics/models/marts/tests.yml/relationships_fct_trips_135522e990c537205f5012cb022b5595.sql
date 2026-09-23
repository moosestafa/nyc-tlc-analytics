
    
    

with child as (
    select dropoff_location_id as from_field
    from `nyc-tlc-analytics-500621`.`dev_marts`.`fct_trips`
    where dropoff_location_id is not null
),

parent as (
    select location_id as to_field
    from `nyc-tlc-analytics-500621`.`dev_marts`.`dim_location`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


