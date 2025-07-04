--get date range from campaign table
with date_range as (
  select
    c.campaign_id
    , c.campaign_name
    , day as transaction_date
  from (
    select
      campaign_id
      , campaign_name
      , start_date
      , end_date
    from grivy.campaigns
    -- be careful of hardcoded filter, best practice would be to create drop down filter in looker studio for monitoring multiple campaign in a single looker report
    where campaign_id = '301'
  ) as c
  cross join unnest(
-- to create timeline chart, create date array to fill in rows with no transaction data
    GENERATE_DATE_ARRAY(start_date, end_date)
  ) as day
),

-- get transactions data
daily_sales as (
  select
    campaign_id
    , transaction_date
    , product_category
    , sum(amount) as total_sales
    , count(transaction_id) as transaction_count
  from grivy.transactions
  where campaign_id = '301'
  group by all
  -- both group by clause has the same effect 
  -- group by campaign_id, transaction_date, product_category
)

select
  d.campaign_id
  , d.campaign_name
  , d.transaction_date
  , s.product_category
  -- fill days with no sales with 0
  , coalesce(s.total_sales, 0) as total_sales
  , coalesce(transaction_count, 0) as transaction_count
from date_range as d
left join daily_sales as s
  on  d.campaign_id = s.campaign_id
  and d.transaction_date = s.transaction_date
order by d.transaction_date, s.product_category;
