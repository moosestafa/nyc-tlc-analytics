-- BigQuery script for the aggregate monthly Yellow, Green, and FHV demand model.
-- Run after `dbt build`; the mart is created in staging_marts.
-- Training ends in August 2023. The six-month forecast covers September 2023
-- through February 2024; December is omitted from scoring because its Yellow
-- and Green source files were incomplete in the warehouse used for evaluation.

CREATE OR REPLACE MODEL `nyc-tlc-analytics-500621.staging_marts.monthly_demand_arima_plus`
OPTIONS (
  MODEL_TYPE = 'ARIMA_PLUS',
  TIME_SERIES_TIMESTAMP_COL = 'month_start',
  TIME_SERIES_DATA_COL = 'trip_count',
  DATA_FREQUENCY = 'MONTHLY',
  HORIZON = 6
) AS
SELECT
  DATE_TRUNC(pickup_date, MONTH) AS month_start,
  SUM(trip_count) AS trip_count
FROM `nyc-tlc-analytics-500621.staging_marts.mart_zone_hourly`
WHERE trip_type IN ('yellow', 'green', 'fhv')
  AND pickup_date >= DATE '2019-03-01'
  AND pickup_date < DATE '2023-09-01'
GROUP BY month_start;

-- Score the five complete holdout months and compare two simple baselines.
-- The last-value baseline repeats August 2023 demand; the seasonal-naive
-- baseline uses demand from the same month one year earlier.
WITH monthly_actuals AS (
  SELECT
    DATE_TRUNC(pickup_date, MONTH) AS month_start,
    SUM(trip_count) AS actual_trips
  FROM `nyc-tlc-analytics-500621.staging_marts.mart_zone_hourly`
  WHERE trip_type IN ('yellow', 'green', 'fhv')
    AND pickup_date >= DATE '2019-03-01'
    AND pickup_date < DATE '2024-03-01'
  GROUP BY month_start
),
holdout AS (
  SELECT month_start, actual_trips
  FROM monthly_actuals
  WHERE month_start BETWEEN DATE '2023-09-01' AND DATE '2024-02-01'
    AND month_start != DATE '2023-12-01'
),
model_forecast AS (
  SELECT
    DATE(forecast_timestamp) AS month_start,
    forecast_value AS predicted_trips
  FROM ML.FORECAST(
    MODEL `nyc-tlc-analytics-500621.staging_marts.monthly_demand_arima_plus`,
    STRUCT(6 AS horizon, 0.8 AS confidence_level)
  )
),
predictions AS (
  SELECT 'ARIMA_PLUS' AS model, h.month_start, h.actual_trips,
         f.predicted_trips
  FROM holdout AS h
  JOIN model_forecast AS f USING (month_start)

  UNION ALL

  SELECT 'Last Value', h.month_start, h.actual_trips,
         aug.actual_trips AS predicted_trips
  FROM holdout AS h
  CROSS JOIN (
    SELECT actual_trips FROM monthly_actuals
    WHERE month_start = DATE '2023-08-01'
  ) AS aug

  UNION ALL

  SELECT 'Seasonal Naive', h.month_start, h.actual_trips,
         prior.actual_trips AS predicted_trips
  FROM holdout AS h
  JOIN monthly_actuals AS prior
    ON prior.month_start = DATE_SUB(h.month_start, INTERVAL 1 YEAR)
)
SELECT
  model,
  COUNT(*) AS holdout_months,
  ROUND(AVG(ABS(actual_trips - predicted_trips))) AS mae,
  ROUND(SQRT(AVG(POW(actual_trips - predicted_trips, 2)))) AS rmse,
  ROUND(100 * AVG(SAFE_DIVIDE(ABS(actual_trips - predicted_trips), actual_trips)), 2) AS mape_pct
FROM predictions
GROUP BY model
ORDER BY CASE model
  WHEN 'ARIMA_PLUS' THEN 1
  WHEN 'Last Value' THEN 2
  ELSE 3
END;
