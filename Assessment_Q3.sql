/* To solve this we first identified savings and investment transactions including their last transaction date,
then we calculated the number of days since their last transaction. */

with all_transactions as (
    -- Savings inflows
    select 
        pp.id as plan_id,
        pp.owner_id,
        'Savings' as type,
        max(sa.transaction_date) as last_transaction_date
	from plans_plan pp
    left join savings_savingsaccount sa on pp.id = sa.plan_id
    where is_regular_savings = 1
    group by pp.id, pp.owner_id

    union all

    -- Investment inflows
    select 
        pp.id as plan_id,
        pp.owner_id,
        'Investment' as type,
        max(sa.transaction_date) as last_transaction_date
    from plans_plan pp
    left join savings_savingsaccount sa on pp.id = sa.plan_id
    where pp.is_a_fund = 1
    group by pp.id, pp.owner_id
),
inactivity_flagged as (
    select 
        plan_id,
        owner_id,
        type,
        last_transaction_date,
        datediff(current_date, last_transaction_date) as inactivity_days
    from all_transactions
    where last_transaction_date < current_date - interval 365 day
)

select *
from inactivity_flagged
order by inactivity_days desc;
