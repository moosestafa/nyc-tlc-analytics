
  
    

    create or replace table `nyc-tlc-analytics-500621`.`dev_marts`.`dim_time_of_day`
      
    
    

    OPTIONS()
    as (
      with hour_spine as (

    select hour
    from unnest(generate_array(0, 23)) as hour

)

select
    hour,
    ltrim(format_time('%I %p', time(hour, 0, 0)), '0') as hour_label,

    case
        when hour between 0 and 5 then 'Late Night'
        when hour between 6 and 11 then 'Morning'
        when hour between 12 and 16 then 'Afternoon'
        when hour between 17 and 20 then 'Evening'
        else 'Night'
    end as time_of_day

from hour_spine
    );
  