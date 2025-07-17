{{ config(materialized='table') }}

select
    md5(symbol) as symbol_key,
    symbol,
    asset_type,
    exchange_name,
    mic_code,
    exchange_timezone,
    currency,
    currency_base,
    currency_quote,
    first_trade_date,
    last_trade_date,
    current_date() as system_current_date,
    true as system_current_flag,
    null as system_end_date,
    first_trade_date as system_start_date,
    current_timestamp() as system_update_date,
    1 as system_version
from {{ ref('vw_symbol_metadata') }}
