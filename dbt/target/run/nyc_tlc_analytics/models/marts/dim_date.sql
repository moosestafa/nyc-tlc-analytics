
  
    

    create or replace table `nyc-tlc-analytics-500621`.`marts`.`dim_date`
      
    
    

    OPTIONS()
    as (
      with date_spine as (

    select full_date
    from unnest(
        generate_date_array(
            date('2009-01-01'),
            date('2026-12-31'),
            interval 1 day
        )
    ) as full_date

)

select
    cast(format_date('%Y%m%d', full_date) as int64) as date_key,
    full_date,

    extract(year from full_date) as year,
    extract(quarter from full_date) as quarter,
    extract(month from full_date) as month,
    format_date('%B', full_date) as month_name,

    extract(day from full_date) as day,
    extract(dayofyear from full_date) as day_of_year,

    extract(dayofweek from full_date) as day_of_week_number,
    format_date('%A', full_date) as day_of_week_name,

    extract(dayofweek from full_date) in (1, 7) as is_weekend

from date_spine
    );
  