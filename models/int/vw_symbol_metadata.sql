{{ config(materialized='view') }}

with unified_assets as (
    select * from {{ ref('stg_transactions') }}
),
symbol_aggregated as (
    select
        symbol,
        min(date_transaction) as first_trade_date,
        max(date_transaction) as last_trade_date,
        any_value(asset_type) as asset_type,
        any_value(exchange_name) as exchange_name,
        any_value(mic_code) as mic_code,
        any_value(exchange_timezone) as exchange_timezone,
        any_value(currency) as currency,
        any_value(currency_base) as currency_base,
        any_value(currency_quote) as currency_quote
    from unified_assets
    group by symbol
)

select * from symbol_aggregated
