{{
  config(
    materialized='table',
    alias='fct_unified_financial_data',
  )
}}

-- Crypto data
with crypto_data as (
    select
        'crypto' as asset_class,
        symbol,
        price_date as transaction_date,
        close_price,
        high_price,
        low_price,
        open_price,
        null as volume,  -- Crypto data doesn't have volume in this example
        currency_base as base_currency,
        currency_quote as quote_currency,
        exchange,
        interval,
        type as asset_type,
        crypto_price_key as unique_key,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ ref('stg_raw_crypto') }}
),

-- ETF data
etf_data as (
    select
        'etf' as asset_class,
        symbol,
        trading_date as transaction_date,
        close_price,
        high_price,
        low_price,
        open_price,
        volume,
        currency as quote_currency,  -- ETFs typically quoted in single currency
        null as base_currency,
        exchange,
        interval,
        instrument_type as asset_type,
        etf_price_key as unique_key,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ ref('stg_raw_etfs') }}
),

-- Forex data
forex_data as (
    select
        'forex' as asset_class,
        symbol,
        trading_date as transaction_date,
        close_rate as close_price,
        high_rate as high_price,
        low_rate as low_price,
        open_rate as open_price,
        null as volume,  -- Forex doesn't typically have volume
        base_currency,
        quote_currency,
        null as exchange,  -- Forex is decentralized
        interval,
        instrument_type as asset_type,
        forex_rate_key as unique_key,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ ref('stg_raw_forex') }}
),

-- Stock data
stock_data as (
    select
        'stock' as asset_class,
        symbol,
        date_transaction as transaction_date,
        close_price,
        high_price,
        low_price,
        open_price,
        volume,
        currency as quote_currency,
        null as base_currency,
        exchange,
        interval,
        asset_type,
        md5(concat_ws('|', symbol, to_varchar(date_transaction))) as unique_key,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ ref('stg_raw_stocks') }}
)

-- Union all data sources
select * from crypto_data
union all
select * from etf_data
union all
select * from forex_data
union all
select * from stock_data