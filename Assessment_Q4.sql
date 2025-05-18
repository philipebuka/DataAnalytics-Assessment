/* In this solution, we first created a customer transaction CTE which calculates the number of transactions and the
average profit per transaction for each customer, then a CTE which calculates customers tenure from the date
when the customer joined the business. Finally we calculated the Customer Life-Time Value */

with customer_transactions as (
    select 
        sa.owner_id,
        count(*) as total_transactions,
        avg(sa.confirmed_amount * 0.001) as avg_profit_per_transaction -- 0.1%
    from savings_savingsaccount sa
    -- where sa.transaction_status = 'success'
    group by sa.owner_id
),
customer_tenure as (
    select 
        uc.id as customer_id,
        concat(uc.first_name," ",uc.last_name) as name,
        timestampdiff(month, uc.date_joined, current_date) as tenure_months
    from users_customuser uc
),
customer_clv as (
    select 
        ct.owner_id as customer_id,
        t.name,
        t.tenure_months,
        ct.total_transactions,
        round(
            (ct.total_transactions / nullif(t.tenure_months, 0)) * 12 * ct.avg_profit_per_transaction,
            2
        ) as estimated_clv
    from customer_transactions ct
    join customer_tenure t on ct.owner_id = t.customer_id
    join users_customuser u on ct.owner_id = u.id
)

select *
from customer_clv
order by estimated_clv desc;
