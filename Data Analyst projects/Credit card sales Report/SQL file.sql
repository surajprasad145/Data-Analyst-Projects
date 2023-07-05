--Sanity check and data cleaning--
--1--
UPDATE [dbo].[customer_acquisation_table]
SET Age = (SELECT AVG(Age) FROM [dbo].[customer_acquisation_table] WHERE Age >= 18)
WHERE Age < 18;

select * from [dbo].[customer_acquisation_table];

--2--

  UPDATE [dbo].[repayment_table]
SET [dbo].[repayment_table].amount = [dbo].[repayment_table].amount + (0.02 * ([dbo].[repayment_table].amount - [dbo].[spend_table].amount))
FROM [dbo].[repayment_table]
JOIN [dbo].[spend_table] ON [dbo].[repayment_table].costomer = [dbo].[spend_table].costomer AND [dbo].[repayment_table].month = DATEADD(MONTH, 1, [dbo].[spend_table].month)
WHERE [dbo].[repayment_table].amount > [dbo].[spend_table].amount;

  select * from [dbo].[repayment_table];
 
 -- Tasks --
  
  --3--
--Monthly Spend of Each Customer--
SELECT Costomer, CONCAT(YEAR(Month), '/', MONTH(Month)) AS Month, SUM(Amount) AS MonthlySpend
FROM [dbo].[spend_table]
GROUP BY Costomer, CONCAT(YEAR(Month), '/', MONTH(Month));

---4---
--Monthly repayment of each customer:--
SELECT Costomer, CONCAT(YEAR(Month), '/', MONTH(Month)) AS Month, SUM(Amount) AS MonthlyRepayment
FROM [dbo].[repayment_table]
GROUP BY Costomer, CONCAT(YEAR(Month), '/', MONTH(Month));

--5--
--Highest Paying 10 customers--
SELECT Costomer, SUM(Amount) AS TotalPayment
FROM [dbo].[repayment_table]
GROUP BY Costomer
ORDER BY TotalPayment DESC 
LIMIT 10;

---6---
--People in which segement are spending more money--
SELECT c.segment, SUM(s.amount) AS TotalSpend
FROM [dbo].[customer_acquisation_table] c
JOIN [dbo].[spend_table] s ON c.customer = s.costomer
GROUP BY c.segment
ORDER BY TotalSpend DESC;

---7--
--Which age group is spending more money:---
SELECT CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
       END AS AgeGroup,
       SUM(s.Amount) AS TotalSpend
FROM [dbo].[customer_acquisation_table] c
JOIN [dbo].[spend_table] s ON c.customer = s.Costomer
GROUP BY CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
       END
ORDER BY TotalSpend DESC;

--8--
--Most profitable segment--
SELECT c.segment, SUM(CAST(r.Amount AS BIGINT)) - SUM(CAST(s.Amount AS BIGINT)) AS Profit
FROM [dbo].[customer_acquisation_table] c
JOIN [dbo].[repayment_table] r ON c.customer = r.Costomer
JOIN [dbo].[spend_table] s ON c.customer = s.Costomer
GROUP BY c.segment
ORDER BY Profit DESC
Limit 1;

--9--
--In which category are customers spending more money:--
SELECT s.Type, SUM(s.Amount) AS TotalSpend
FROM [dbo].[spend_table] s
GROUP BY s.Type
ORDER BY TotalSpend DESC;

--10--
--Monthly Profit for the bank--

WITH RepaymentSummary AS (
  SELECT CONCAT(YEAR(Month), '/', MONTH(Month)) AS Month, SUM(Amount) AS MonthlyRepayment
  FROM [dbo].[repayment_table]
  GROUP BY CONCAT(YEAR(Month), '/', MONTH(Month))
),
SpendSummary AS (
  SELECT CONCAT(YEAR(Month), '/', MONTH(Month)) AS Month, SUM(Amount) AS MonthlySpend
  FROM [dbo].[spend_table]
  GROUP BY CONCAT(YEAR(Month), '/', MONTH(Month))
)
SELECT r.Month, r.MonthlyRepayment, s.MonthlySpend, (r.MonthlyRepayment - s.MonthlySpend) AS MonthlyProfit
FROM RepaymentSummary r
JOIN SpendSummary s ON r.Month = s.Month;

--11--

--Impose an interest rate of 2.9% for each customer for any due amount--

UPDATE [dbo].[spend_table]
SET amount = amount + (0.029 * Due_amount)
FROM (
  SELECT s.costomer, s.month, (s.amount - r.amount) AS Due_amount
  FROM [dbo].[spend_table] s
  INNER JOIN [dbo].[repayment_table] r ON r.costomer = s.costomer AND r.month = s.month
  WHERE  s.amount > r.Amount
) AS Due
WHERE [dbo].[spend_table].costomer = Due.costomer
  AND [dbo].[spend_table].month = Due.month;

  select * from [dbo].[spend_table];














