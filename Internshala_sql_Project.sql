/*
Video explanation link is : " https://drive.google.com/file/d/1xcNOPFzC9OyOBxZ_Tk9dCdbMk1imz7zY/view?usp=sharing "
Kindly copy and past the above link to access my video explanation.
*/

# Viewing the dataset
select *
from walmartsales;

# Task ONE
WITH Monthly_Sales AS (
    SELECT 
        Branch,
        DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS Sale_Month,
        SUM(Total) AS Monthly_Total
    FROM 
        walmartsales
    GROUP BY 
        Branch, Sale_Month
),

Growth_Rates AS (
    SELECT 
        Branch,
        Sale_Month,
        Monthly_Total,
        LAG(Monthly_Total) OVER (PARTITION BY Branch ORDER BY Sale_Month) AS Previous_Month_Total
    FROM 
        Monthly_Sales
)

SELECT 
    Branch,
    SUM(Monthly_Total) AS Total_Sales,
    SUM(Monthly_Total - Previous_Month_Total) AS Growth_Amount,
    AVG((Monthly_Total - Previous_Month_Total) / NULLIF(Previous_Month_Total, 0)) * 100 AS Growth_Rate
FROM 
    Growth_Rates
WHERE 
    Previous_Month_Total IS NOT NULL
GROUP BY 
    Branch
ORDER BY 
    Growth_Rate DESC
LIMIT 1;


# Task TWO
WITH profit_per_product_line AS (
    SELECT branch, product_line, 
           SUM(cogs-gross_income) AS profit_margin
    FROM walmartsales
    GROUP BY branch, product_line
)

SELECT branch, product_line, profit_margin
FROM profit_per_product_line
WHERE (branch, profit_margin) IN (
    SELECT branch, MAX(profit_margin)
    FROM profit_per_product_line
    GROUP BY branch
)
ORDER BY branch;

# Task THREE
WITH customer_spending AS (
    SELECT 
        customer_id, 
        SUM(total) AS total_spent
    FROM 
        walmartsales
    GROUP BY 
        customer_id
)

SELECT 
    customer_id, 
    total_spent,
    CASE 
        WHEN total_spent > (SELECT AVG(total_spent) * 2 FROM customer_spending) THEN 'High'
        WHEN total_spent BETWEEN (SELECT AVG(total_spent) FROM customer_spending) AND (SELECT AVG(total_spent) * 2 FROM customer_spending) THEN 'Medium'
        ELSE 'Low'
    END AS spending_tier
FROM 
    customer_spending
ORDER BY customer_id;

# Task FOUR
WITH avg_sales AS (
    SELECT 
        product_line, 
        AVG(total) AS avg_total
    FROM 
        walmartsales
    GROUP BY 
        product_line
),
anomalies AS (
    SELECT 
        w.*,
        a.avg_total,
        ABS(w.total - a.avg_total) AS deviation
    FROM 
        walmartsales w
    JOIN 
        avg_sales a
    ON 
        w.product_line = a.product_line
)
SELECT branch, customer_id, gender, product_line, avg_total, deviation
FROM anomalies
WHERE deviation > (SELECT STDDEV(total) FROM walmartsales);

# Task FIVE
WITH payment_counts AS (
    SELECT city, payment, COUNT(*) AS count
    FROM walmartsales
    GROUP BY city, payment
)
SELECT city, payment, count
FROM payment_counts
WHERE (city, count) IN (
    SELECT city, MAX(count)
    FROM payment_counts
    GROUP BY city
)
ORDER BY city;

# Task SIX
SELECT 
    gender, 
    DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS Month, 
    SUM(Total) AS Total_Sales
FROM 
    walmartsales
GROUP BY 
    gender, Month
ORDER BY 
    Month;

# Task SEVEN
SELECT customer_type, product_line, total_sales
FROM (
    SELECT customer_type, product_line, SUM(Total) AS total_sales,
           ROW_NUMBER() OVER (PARTITION BY customer_type ORDER BY SUM(Total) DESC) AS rank_assigned
    FROM walmartsales
    GROUP BY customer_type, product_line
) AS ranked
WHERE rank_assigned = 1;

# Task EIGHT
SELECT Customer_ID, COUNT(DISTINCT Invoice_ID) AS transaction_count
FROM walmartsales
GROUP BY Customer_ID
HAVING transaction_count > 1;

# Task NINE
SELECT Customer_ID, SUM(Total) AS total_sales
FROM walmartsales
GROUP BY Customer_ID
ORDER BY total_sales DESC
LIMIT 5;

# Task TEN
SELECT 
    DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y')) AS day_of_week,
    SUM(Total) AS total_sales
FROM 
    walmartsales
GROUP BY 
    day_of_week
ORDER BY 
    total_sales DESC;