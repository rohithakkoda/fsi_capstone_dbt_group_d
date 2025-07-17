{{
  config(
    materialized = 'table',
    alias = 'stg_raw_crypto'
  )
}}

with source_data as (
    select
        try_parse_json(content) as json_data,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ source('raw', 'RAW_CRYPTO') }}
      -- Filter for ADA/USD data only
),

extracted as (
    select
        json_data:status::string as status,
        json_data:meta:currency_base::string as currency_base,
        json_data:meta:currency_quote::string as currency_quote,
        json_data:meta:exchange::string as exchange,
        json_data:meta:interval::string as interval,
        json_data:meta:symbol::string as symbol,
        json_data:meta:type::string as type,
        f.value:close::float as close_price,
        f.value:datetime::date as price_date,
        f.value:high::float as high_price,
        f.value:low::float as low_price,
        f.value:open::float as open_price,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from source_data,
    lateral flatten(input => json_data:values) f
)

select
    *,
    {{ dbt_utils.generate_surrogate_key(['symbol', 'price_date']) }} as crypto_price_key
from extracted
where status = 'ok'  -- Only include successful records