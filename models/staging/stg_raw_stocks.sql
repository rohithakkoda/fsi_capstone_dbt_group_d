{{ config(materialized='table') }}

-- Step 1: Extract raw data and JSON parse
with source as (

    select
        content::variant as data,
        metadata_filename,
        metadata_file_row_number,
        _ingested_at
    from {{ source('raw', 'RAW_STOCKS') }}

),

-- Step 2: Flatten the 'values' array
flattened as (

    select
        data:meta:symbol::string                  as symbol,
        data:meta:exchange::string                as exchange,
        data:meta:exchange_timezone::string       as exchange_timezone,
        data:meta:interval::string                as interval,
        data:meta:mic_code::string                as mic_code,
        data:meta:currency::string                as currency,
        data:meta:type::string                    as asset_type,

        value:value:datetime::timestamp           as date_transaction,
        value:value:open::float                   as open_price,
        value:value:high::float                   as high_price,
        value:value:low::float                    as low_price,
        value:value:close::float                  as close_price,
        value:value:volume::int                   as volume,

        metadata_filename,
        metadata_file_row_number,
        _ingested_at

    from source,
         lateral flatten(input => data:values) as value

    where data:status::string = 'ok'

)

-- Step 3: Final output
select * from flattened
