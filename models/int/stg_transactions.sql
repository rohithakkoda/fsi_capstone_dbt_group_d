{{ config(materialized='table') }}
with stg_stocks as (
    select
        symbol,
        trading_date                              as date_transaction,
        open_price,
        close_price,
        high_price,
        low_price,
        volume                           as trade_volume,
        'stock'                                 as asset_type,
        exchange                                as exchange_name,
        mic_code,
        exchange_timezone,
        currency,
        null                                    as currency_base,
        null                                    as currency_quote
    from {{ ref('stg_raw_stocks') }}
),
stg_etf as (
    select
        symbol,
        trading_date                              as date_transaction,
        open_price,
        close_price,
        high_price,
        low_price,
        volume                           as trade_volume,
        'etf'                                   as asset_type,
        exchange                                as exchange_name,
        mic_code,
        exchange_timezone,
        currency,
        null                                    as currency_base,
        null                                    as currency_quote
    from {{ ref('stg_raw_etfs') }}
),
stg_forex as (
    select
        symbol,
        trading_date                              as date_transaction,
        open_rate as open_price,
        close_rate as close_price,
        high_rate as high_price,
        low_rate as low_price,
        null                                    as trade_volume,
        'forex'                                 as asset_type,
        null                                    as exchange_name,
        null                                    as mic_code,
        null                                    as exchange_timezone,
        null                                    as currency,
        base_currency as currency_base,
        quote_currency as currency_quote
    from {{ ref('stg_raw_forex') }}
),
stg_crypto as (
    select
        symbol,
        price_date                              as date_transaction,
        open_price,
        close_price,
        high_price,
        low_price,
        null                                    as trade_volume,
        'crypto'                                as asset_type,
        exchange                                as exchange_name,
        null                                    as mic_code,
        null                                    as exchange_timezone,
        null                                    as currency,
        currency_base,
        currency_quote
    from {{ ref('stg_raw_crypto') }}
)
select * from stg_stocks
union all
select * from stg_etf
union all
select * from stg_forex
union all
select * from stg_crypto






