-- Calculate estimated Customer Lifetime Value (CLV) and engagement metrics
SELECT 
    u.id AS customer_id,
    u.first_name,

    -- Date the user signed up
    DATE(u.created_on) AS signup_date,

    -- Tenure in months since signup
    ROUND((JULIANDAY('now') - JULIANDAY(u.created_on)) / 30.0, 1) AS tenure_months,

    -- Total number of savings transactions
    COUNT(s.id) AS total_transactions,

    -- Total confirmed amount saved by user, converted to kobo (assuming original is in naira)
    SUM(s.confirmed_amount) * 0.001 AS total_profit_kobo,

    -- Estimated CLV: (Total profit / tenure in months) * 12 months
    ROUND(
        ((SUM(s.confirmed_amount) * 0.001) / ((JULIANDAY('now') - JULIANDAY(u.created_on)) / 30.0)) * 12,
        2
    ) AS estimated_clv_kobo

FROM 
    users_customuser u

-- Join plans to connect users with their savings plans
JOIN 
    plans_plan p ON p.owner_id = u.id

-- Join savings transactions linked to those plans
JOIN 
    savings_savingsaccount s ON s.plan_id = p.id

GROUP BY 
    u.id, u.first_name;