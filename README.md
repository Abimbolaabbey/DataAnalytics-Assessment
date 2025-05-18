# DataAnalytics-Assessment


# SQL Assessment: Customer Activity and Value Analysis

## Overview
This project involves a set of analytical SQL queries designed to assess customer engagement, transaction frequency, deposit value, inactivity, and estimated lifetime value (CLV) using a financial application database. The tables used include:

- users_customuser – customer records
- plans_plan – savings or investment plans
- savings_savingsaccount – savings transactions
- withdrawals_withdrawal -  records of withdrawal transactions

---

## Query 1: Total Deposits by Customer

### Objective:
To compute each customer's total deposit, combining both confirmed savings and investment amounts.

### Approach:
- I used aggregate confirmed_amount from savings_savingsaccount (joined through plans_plan).
- Aggregate was also used for cowry_amount from plans_plan (only where is_a_fund = 1).
- Used COALESCE to handle nulls when summing deposits.
- Filtered out customers with no deposits.

### Challenges And Resolution:
- I ensured all customers are represented, even with missing data.
- Used subqueries for accurate grouping and efficient computation.

---

## Query 2: Customer Transaction Frequency Category

### Objective:
To classify customers based on their average monthly transaction frequency.

### Approach:
- Counted all savings transactions (s.id) per customer.
- Calculated months active using:  
  JULIANDAY('now') - JULIANDAY(MIN(s.created_on)).
- Computed average transactions per month and categorize as:
  - *High Frequency* (>= 10/month)
  - *Medium Frequency* (3–9/month)
  - *Low Frequency* (< 3/month)

### Challenges And Resolution:
- I used MAX(1, active_days) to avoid division by zero.
- Also used ROUND for consistent frequency values.

---

## Query 3: Inactive Customers (>365 Days)

### Objective:
Identified customers whose last transaction or plan activity occurred over one year ago.

### Approach:
- COALESCE(s.created_on, p.created_on) was used to capture the latest activity.
- I used Apply MAX(...) to get the most recent date.
- Filtered with:  
  DATE(last_transaction_date) <= DATE('now', '-365 days')

### Challenge And Resolution:
- *SQLite Limitation*: Could not nest MAX(...) inside JULIANDAY(...) directly.
- *Resolution: Used a **Common Table Expression (CTE)* to first extract last_transaction_date, then calculated inactive_days in the main query.

---

## Query 4: Estimate Customer Lifetime Value (CLV)

### Objective
Estimate annual CLV by analyzing customer tenure and total confirmed savings.

### Approach:
- Computed tenure_months as the difference between today and u.created_on.
- Converted total confirmed savings to kobo (× 0.001).
- Calculated CLV as:
  - Monthly Avg Profit × 12
  - Formula:  
    ((SUM(s.confirmed_amount) * 0.001) / tenure_months) * 12

### Challenges And Resolution:
- I avoided division by zero by ensuring all users had valid creation dates and at least one transaction.
- Initial error due to using ROUND(JULIANDAY(...) - JULIANDAY(MAX(...))) directly in SQLite.
- *Resolution*: Refactored using CTE and CAST(... AS INTEGER) to make it compatible with SQLite’s evaluation order.
