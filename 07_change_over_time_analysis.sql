USE [DataWarehouse];
GO


SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    YEAR(order_date),
    MONTH(order_date);
GO

-- Monthly analysis using DATETRUNC()

SELECT
    DATETRUNC(month, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);
GO

-- Monthly analysis with a readable month label

SELECT
    FORMAT(
        DATETRUNC(month, order_date),
        'yyyy-MMM'
    ) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);
GO