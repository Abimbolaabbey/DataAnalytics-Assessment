-- Step 1: Get last transaction date per customer
WITH customer_activity AS (
    SELECT 
        u.id AS customer_id,
        u.first_name,
        MAX(COALESCE(s.created_on, p.created_on)) AS last_transaction_date
    FROM 
        users_customuser u
    LEFT JOIN 
        plans_plan p ON p.owner_id = u.id
    LEFT JOIN 
        savings_savingsaccount s ON s.plan_id = p.id
    GROUP BY 
        u.id, u.first_name
)

-- Step 2: Select from that and compute inactivity duration
SELECT 
    customer_id,
    first_name,
    last_transaction_date,
    CAST(JULIANDAY('now') - JULIANDAY(last_transaction_date) AS INTEGER) AS inactive_days
FROM 
    customer_activity
WHERE 
    DATE(last_transaction_date) <= DATE('now', '-365 days');