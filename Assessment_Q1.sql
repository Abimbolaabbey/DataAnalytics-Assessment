-- Select customer details along with their total deposits from savings and investments
SELECT 
    u.id AS customer_id,
    u.first_name AS customer_name,
    u.email AS customer_email,

    -- Add savings and investment amounts using COALESCE to handle NULLs
    COALESCE(save.total_savings_kobo, 0) + COALESCE(invest.total_invest_kobo, 0) AS total_deposits_kobo

FROM 
    users_customuser u

-- Subquery: Calculate total confirmed savings per customer
LEFT JOIN (
    SELECT 
        p.owner_id, 
        SUM(s.confirmed_amount) AS total_savings_kobo
    FROM 
        savings_savingsaccount s
        JOIN plans_plan p ON p.id = s.plan_id  -- Join to link savings to plan owner
    GROUP BY 
        p.owner_id
) save ON save.owner_id = u.id  -- Join savings data to user

-- Subquery: Calculate total investment amount per customer
LEFT JOIN (
    SELECT 
        owner_id, 
        SUM(cowry_amount) AS total_invest_kobo
    FROM 
        plans_plan
    WHERE 
        is_a_fund = 1                -- Only include fund-type plans
        AND cowry_amount > 0         -- Only include positive investment values
    GROUP BY 
        owner_id
) invest ON invest.owner_id = u.id  -- Join investment data to user

-- Filter: Only include users who have either savings or investments
WHERE 
    save.total_savings_kobo IS NOT NULL
    OR invest.total_invest_kobo IS NOT NULL

-- Sort users by total deposits in descending order
ORDER BY 
    total_deposits_kobo DESC;