USE [DataWarehouse];
GO

/*
========================================================
Product Report

Creates one summarized row for every sold product.
========================================================
*/

CREATE OR ALTER VIEW [gold].[report_products]
AS

WITH base_query AS
(
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost

    FROM [gold].[fact_sales] AS f

    LEFT JOIN [gold].[dim_prod] AS p
        ON f.product_key = p.product_key

    WHERE f.order_date IS NOT NULL
),

product_aggregations AS
(
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        DATEDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan_months,

        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        ROUND(
            AVG(
                CAST(sales_amount AS DECIMAL(18, 2))
                / NULLIF(quantity, 0)
            ),
            2
        ) AS average_selling_price

    FROM base_query

    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,

    DATEDIFF(
        MONTH,
        last_sale_date,
        GETDATE()
    ) AS recency_months,

    CASE
        WHEN total_sales > 50000
            THEN 'High-Performer'

        WHEN total_sales >= 10000
            THEN 'Mid-Range'

        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan_months,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    average_selling_price,

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE CAST(total_sales AS DECIMAL(18, 2))
             / total_orders
    END AS average_order_revenue,

    CASE
        WHEN lifespan_months = 0
            THEN CAST(total_sales AS DECIMAL(18, 2))
        ELSE CAST(total_sales AS DECIMAL(18, 2))
             / lifespan_months
    END AS average_monthly_revenue

FROM product_aggregations;
GO