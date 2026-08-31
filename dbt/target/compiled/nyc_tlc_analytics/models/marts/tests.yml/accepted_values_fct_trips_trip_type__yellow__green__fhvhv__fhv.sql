
    
    

with all_values as (

    select
        trip_type as value_field,
        count(*) as n_records

    from `nyc-tlc-analytics-500621`.`marts`.`fct_trips`
    group by trip_type

)

select *
from all_values
where value_field not in (
    'yellow','green','fhvhv','fhv'
)


