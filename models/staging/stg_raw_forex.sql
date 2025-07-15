{{
  config(
    materialized='table',
    alias='stg_raw_forex'
  )
}}

with source_data as (
    select
        try_parse_json(content) as json_data,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ source('raw', 'RAW_FOREX') }}
    where metadata_filename like '%AUD_USD%'  -- Filter for AUD/USD data
),

extracted as (
    select
        json_data:meta:currency_base::string as base_currency,
        json_data:meta:currency_quote::string as quote_currency,
        json_data:meta:interval::string as interval,
        json_data:meta:symbol::string as symbol,
        json_data:meta:type::string as instrument_type,
        json_data:status::string as status,
        f.value:close::float as close_rate,
        f.value:datetime::date as trading_date,
        f.value:high::float as high_rate,
        f.value:low::float as low_rate,
        f.value:open::float as open_rate,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at,
        -- Calculate daily spread (high - low)
        f.value:high::float - f.value:low::float as daily_spread,
        -- Calculate price change percentage
        round((f.value:close::float - f.value:open::float) / f.value:open::float * 100, 4) as daily_change_pct
    from source_data,
    lateral flatten(input => json_data:values) f
)

select
    *,
    md5(concat_ws('|', symbol, to_varchar(trading_date))) as forex_rate_key,
    current_timestamp() as dbt_updated_at
from extracted
where status = 'ok'  -- Only include successful records