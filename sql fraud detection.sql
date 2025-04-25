use bank;
SELECT * FROM transactions limit 10;

-- 1. Detecting Recursive Fraudulent Transactions

WITH RECURSIVE fraud_chain as (
SELECT nameOrig as initial_account,
nameDest as next_account,
step,
amount,
newbalanceorig
FROM 
transactions
WHERE isFraud = 1 and type = 'TRANSFER'

UNION ALL 

SELECT fc.initial_account,
t.nameDest,t.step,t.amount ,t.newbalanceorig
FROM fraud_chain fc
JOIN transactions t
ON fc.next_account = t.nameorig and fc.step < t.step 
where t.isfraud = 1 and t.type = 'TRANSFER')

SELECT * FROM fraud_chain;

-- Analyzing fraudulent activity over time

WITH rolling_fraud AS (
    SELECT nameOrig, step,
           SUM(isFraud) OVER (
               PARTITION BY nameOrig 
               ORDER BY step 
               ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
           ) AS fraud_rolling
    FROM transactions
    LIMIT 10000
)
SELECT * FROM rolling_fraud;


-- 3. Complex Fraud Detection Using Multiple CTEs
-- Question:
-- Use multiple CTEs to identify accounts with suspicious activity, including large transfers, consecutive transactions without balance change, and flagged transactions.

WITH large_transfers as (
SELECT nameOrig,step,amount FROM transactions WHERE type = 'TRANSFER' and amount >500000),
no_balance_change as (
SELECT nameOrig,step,oldbalanceOrg,newbalanceOrig FROM transactions where oldbalanceOrg=newbalanceOrig),
flagged_transactions as (
SELECT nameOrig,step FROM transactions where  isflaggedfraud = 1) 

SELECT 
    lt.nameOrig
FROM 
    large_transfers lt
JOIN 
    no_balance_change nbc ON lt.nameOrig = nbc.nameOrig AND lt.step = nbc.step
JOIN 
    flagged_transactions ft ON lt.nameOrig = ft.nameOrig AND lt.step = ft.step;


-- 4. Write me a query that checks if the computed new_updated_Balance is the same as the actual newbalanceDest in the table. If they are equal, it returns those rows.

with CTE as (
SELECT amount,nameorig,oldbalancedest,newbalanceDest,(amount+oldbalancedest) as new_updated_Balance 
FROM transactions
)
SELECT * FROM CTE where new_updated_Balance = newbalanceDest;

