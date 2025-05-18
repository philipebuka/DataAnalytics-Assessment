/* To solve this challenge, we first calculated customers average transaction per month
then we segmented them by categorizing their transaction frequencies*/

with customer_avg_tx as (
    select owner_id, avg(monthly_tx_count) as avg_tx_per_month
    from 
    -- subquery to count number of transactions for each customer by month
    (select 
        sa.owner_id,
        date_format(transaction_date, '%Y-%m') as tx_month,
        count(*) as monthly_tx_count
    from savings_savingsaccount sa
    where sa.transaction_status = 'success'  -- Capture only succesful transactions
    group by sa.owner_id, tx_month) as customer_monthly_tx
    
    group by owner_id
),

-- Segment customers by average transaction frequency
customer_segments as (
    select 
        ca.owner_id,
        concat(u.first_name," ",u.last_name) as name,
        round(ca.avg_tx_per_month, 2) as avg_tx_per_month,
        case
            when ca.avg_tx_per_month >= 10 then 'High Frequency'
            when ca.avg_tx_per_month between 3 and 9 then 'Medium Frequency'
            else 'Low Frequency'
        end as frequency_segment
    from customer_avg_tx ca
    join users_customuser u on ca.owner_id = u.id
)

select * 
from customer_segments
order by avg_tx_per_month desc;