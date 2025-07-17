{{ config(materialized='table') }}

with distinct_dates as (
    select distinct date_transaction from {{ ref('stg_transactions') }}
),
date_dim as (
    select
        date_transaction,
        day(date_transaction) as day_of_month,
        dayofweekiso(date_transaction) as day_of_week,
        dayofyear(date_transaction) as day_of_year,
        md5(cast(date_transaction as string)) as dim_transaction_key,
        monthname(date_transaction) as month_name,
        month(date_transaction) as month_num,
        quarter(date_transaction) as quarter_num,
        current_date() as system_current_date,
        true as system_current_flag,
        null as system_end_date,
        date_transaction as system_start_date,
        current_timestamp() as system_update_date,
        1 as system_version,
        to_char(date_transaction, 'YYYY-MM') as year_month,
        year(date_transaction) as year_num,
        concat(year(date_transaction), '-Q', quarter(date_transaction)) as year_quarter
    from distinct_dates
)

select * from date_dim
