/*  sav_inv_summary CTE helps to count the number of savings and investments made by each owner, and hv_customers 
CTE helps to calculate High-value customers by summing up the total deposite for each owner. */

with sav_inv_summary as (
    select owner_id, 
           sum(coalesce(is_regular_savings,0)) as savings_count,
           sum(coalesce(is_a_fund,0)) as investment_count
    from plans_plan
    group by owner_id
),
hv_customers as (
    select 
        uc.id as owner_id,
        concat(uc.first_name," ",uc.last_name) as name, -- concat first name and last name
        si.savings_count as savings_count,
        si.investment_count as investment_count,
        sum(coalesce(sa.confirmed_amount,0)) as total_deposites
    from users_customuser uc
    left join sav_inv_summary si on uc.id = si.owner_id
    left join savings_savingsaccount sa on uc.id = sa.owner_id
    group by owner_id
)
select *
from hv_customers
where savings_count > 0 and investment_count > 0
order by investment_count desc;

