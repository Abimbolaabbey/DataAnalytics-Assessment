-- Select customers and calculate their transaction frequency category
SELECT 
    u.id AS customer_id,
    u.first_name,

    -- Total number of transactions (savings entries)
    COUNT(s.id) AS total_transactions,

    -- Average number of transactions per month
    ROUND(
        COUNT(s.id) * 1.0 / MAX(1, JULIANDAY('now') - JULIANDAY(MIN(s.created_on))) * 30, 
        2
    ) AS avg_txn_per_month,

    -- Categorize customer based on average monthly transactions
    CASE 
        WHEN COUNT(s.id) * 1.0 / MAX(1, JULIANDAY('now') - JULIANDAY(MIN(s.created_on))) * 30 >= 10 
            THEN 'High Frequency'
        WHEN COUNT(s.id) * 1.0 / MAX(1, JULIANDAY('now') - JULIANDAY(MIN(s.created_on))) * 30 BETWEEN 3 AND 9 
            THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category

FROM 
    users_customuser u

-- Join plans to link customers to their savings accounts
JOIN 
    plans_plan p ON p.owner_id = u.id

-- Join savings transactions linked to each plan
JOIN 
    savings_savingsaccount s ON s.plan_id = p.id

GROUP BY 
    u.id, u.first_name;