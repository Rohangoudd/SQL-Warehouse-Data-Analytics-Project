USE [DataWarehouse];
GO

/*
========================================================
Cumulative Analysis

Business questions:
1. What are the total sales for each year?
2. How have sales accumulated over time?
3. How has the average product price changed?
========================================================
*/

SELECT
    order_year,
    total_sales,

    SUM(total_sales) OVER (
        ORDER BY order_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,

    AVG(avg_price) OVER (
        ORDER BY order_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS moving_average_price

FROM
(
    SELECT
        DATETRUNC(year, order_date) AS order_year,
        SUM(sales_amount) AS total_sales,
        AVG(CAST(price AS DECIMAL(18, 2))) AS avg_price
    FROM [gold].[fact_sales]
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) AS yearly_sales

ORDER BY order_year;
GO