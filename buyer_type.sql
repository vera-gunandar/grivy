with cust_tx as (
  select
    c.target_audience
    , t.customer_id
    , count(*) as tx_cnt
    , sum(t.amount) as total_spent
  from grivy.transactions as t
  join grivy.campaigns as c using (campaign_id)
  group by target_audience, customer_id
)


select
  -- classify whether user is repeat buyer or new buyer
  -- though ideally should not use campaign data and only use transaction table as reference
  -- however, as the data is very limited, we try to enrich where acceptable
  -- assuming loyal customer = repeat buyer & All Customers or New Customer = new buyer
  case when lower(target_audience) like '%loyal%' or tx_cnt > 1 then 'repeat buyer'
    else 'new buyer' end as buyer_type
  , avg(total_spent) as average_spending
from cust_tx
group by buyer_type
order by buyer_type
