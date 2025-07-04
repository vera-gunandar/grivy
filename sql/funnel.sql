with agg_transaction_subq as (
select
  sum(amount) as revenue
  , count(transaction_id) as transaction_count
  , campaign_id
from grivy.transactions
group by campaign_id
)

, campaign_metrics_subq as (
select *
from grivy.campaign_metrics
join agg_transaction_subq using (campaign_id)
)

select *
from campaign_metrics_subq
unpivot ( metrics for dimentions in (
  transaction_count
  , clicks
  , impressions
  , website_landing_hits
))
-- be careful of hardcoded filter, i recommend to use dropdown filter in looker studio in real use case for more versatile & interactive report
where campaign_id = '301'