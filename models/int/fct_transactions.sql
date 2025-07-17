{{ config(materialized='table') }}

select
    s.symbol,
    s.date_transaction,
    s.open_price,
    s.close_price,
    s.high_price,
    s.low_price,
    s.trade_volume,
    current_date() as system_current_date,
    current_timestamp() as system_update_date
from {{ ref('stg_transactions') }} s
