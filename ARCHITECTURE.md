# NYC TLC Analytics Architecture

This file documents how data moves through the project.

## End-to-End Pipeline

```mermaid
flowchart LR
    A[NYC TLC<br/>Monthly Parquet Files]
    B[Python Ingestion<br/>Download + Normalize]
    C[(Google Cloud Storage<br/>Raw Landing)]
    D[(BigQuery Raw<br/>Source Tables)]
    E[dbt Staging]
    F[dbt Core Models<br/>Dimensions + fct_trips]
    G[(mart_zone_hourly)]
    H[Google Data Studio<br/>Dashboard]
    I[BigQuery ML<br/>ARIMA_PLUS]
    J[(ops.ingestion_log)]
    K[GitHub Actions<br/>Scheduled Pipeline]

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    G --> I
    B --> J
    K -. triggers .-> B
    K -. runs .-> E
```

## Ingestion Flow

```mermaid
flowchart TD
    A[Start service-month]
    B{Object exists in GCS?}
    C[Download TLC Parquet]
    D[Normalize schema]
    E[Upload to GCS]
    F[Read GCS generation<br/>as source_version]
    G{Exact source version<br/>already loaded?}
    H[Load into BigQuery]
    I[Record loaded status]
    J[Skip BigQuery load]
    K[Record failure<br/>and raise]

    A --> B
    B -- No --> C
    C --> D
    D --> E
    B -- Yes --> F
    E --> F
    F --> G
    G -- Yes --> J
    G -- No --> H
    H --> I
    C -. error .-> K
    D -. error .-> K
    E -. error .-> K
    H -. error .-> K
```

## Warehouse Model

```mermaid
flowchart TD
    Y[stg_yellow]
    G[stg_green]
    F[stg_fhv]
    H[stg_fhvhv]

    D1[dim_date]
    D2[dim_location]
    D3[dim_time_of_day]

    T[(fct_trips)]
    M[(mart_zone_hourly)]

    Y --> T
    G --> T
    F --> T
    H --> T

    D1 --> T
    D2 --> T
    D3 --> T

    T --> M
```

`fct_trips` standardizes the trip sources into a shared trip-level schema.

`mart_zone_hourly` aggregates the fact table to:

```text
pickup_date
× pickup_hour
× trip_type
× pickup_location_id
```

## Analytics and ML

```mermaid
flowchart LR
    M[(mart_zone_hourly)]
    D[Google Data Studio]
    A[Monthly Demand Aggregation]
    B[BigQuery ML<br/>ARIMA_PLUS]
    C[Forecast]
    E[Holdout Evaluation]
    F[Baseline Comparison]

    M --> D
    M --> A
    A --> B
    B --> C
    C --> E
    E --> F
```

The dashboard uses the hourly zone mart directly.

The forecasting path aggregates the mart to monthly combined demand, trains an `ARIMA_PLUS` model, evaluates it on held-out months, and compares it against last-value and seasonal-naive baselines.

## Reliability Design

The pipeline intentionally treats these as different states:

```text
Object exists in GCS
```

and:

```text
That exact object version loaded successfully into BigQuery
```

`ops.ingestion_log` and the GCS object generation ID are used to track the second state.

This allows a source file that landed successfully but failed during BigQuery loading to be retried instead of being permanently skipped.

## Current Boundaries

- FHVHV is not part of the main comparable analytics path because coverage is incomplete.
- Raw loads use `WRITE_APPEND`, so arbitrary source replacement is not fully idempotent.
- Newly expected TLC files can occasionally fail because of upstream publication/access behavior.
- The current ML model forecasts total monthly demand rather than zone-level demand.
