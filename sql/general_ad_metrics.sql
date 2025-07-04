with agg_transaction as (
  select
    campaign_id
    , count(transaction_id) as transaction_count
    , sum(amount) as revenue
  from grivy.transactions
  -- be careful of hardcoded filter, for more versatile & interactive report...i recommend to use dropdown filter in looker studio instead
  where campaign_id = '301'
  group by campaign_id
)
SELECT
  c.campaign_id
  , c.campaign_name
  , c.budget
  , m.clicks
  , m.impressions
  , m.website_landing_hits
-- use safe divide instead of "/" in case there's 0 denominator,
-- the sampe data doens't have that,
-- but for larger dataset, i recommend to use safe_divide as usually there's always 0 denominator which cause the SQL to break
  , safe_divide(m.clicks, m.impressions) as ctr
-- assuming budget = the amount that has been spent on the campaign
  , safe_divide(c.budget, m.clicks) as cpc
  , safe_divide(c.budget, t.transaction_count) as cost_per_transactions
  , safe_divide(t.revenue - c.budget, c.budget) as roi
  , safe_divide(m.website_landing_hits - t.transaction_count,
              m.website_landing_hits) as bounce_rate
  , safe_divide(t.transaction_count, m.website_landing_hits) as post_click_cr
  , safe_divide(t.transaction_count, m.impressions) as conversion_rate
  , safe_divide(clicks - website_landing_hits, clicks) as click_to_landing_loss
  , t.transaction_count
  , t.revenue
from grivy.campaigns as c
join grivy.campaign_metrics as m using (campaign_id)
left join agg_transaction as t using (campaign_id)
where campaign_id = '301'
