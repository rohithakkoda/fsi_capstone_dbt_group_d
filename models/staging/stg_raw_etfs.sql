{{
  config(
    materialized='table',
    alias='stg_raw_etfs'
  )
}}

with source_data as (
    select
        try_parse_json(content) as json_data,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ source('raw', 'RAW_ETFS') }}
    where metadata_filename like '%AGG%'  -- Filter for AGG ETF data
),

extracted as (
    select
        json_data:meta:currency::string as currency,
        json_data:meta:exchange::string as exchange,
        json_data:meta:exchange_timezone::string as exchange_timezone,
        json_data:meta:interval::string as interval,
        json_data:meta:mic_code::string as mic_code,
        json_data:meta:symbol::string as symbol,
        json_data:meta:type::string as instrument_type,
        json_data:status::string as status,
        f.value:close::float as close_price,
        f.value:datetime::date as trading_date,
        f.value:high::float as high_price,
        f.value:low::float as low_price,
        f.value:open::float as open_price,
        f.value:volume::int as volume,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from source_data,
    lateral flatten(input => json_data:values) f
)

select
    *,
    md5(concat_ws('|', symbol, to_varchar(trading_date))) as etf_price_key,
    current_timestamp() as dbt_updated_at
from extracted
where status = 'ok'  -- Only include successful records