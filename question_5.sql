
WITH category_profit AS(
    SELECT
    p.category, 
    SUM(p.sale_price - p.cost_price) AS profit
    FROM orders o
    JOIN dim_product p ON o.product_code = p.product_code
    JOIN dim_store s ON o.store_code = s.store_code
    JOIN dim_date d ON o.order_date = d.date
    WHERE s.full_region = 'Wiltshire, UK'
    AND d.year = 2021
    GROUP BY p.category)

, ranked_profit AS (
    SELECT
    category,
    profit,
    RANK() OVER (ORDER BY profit DESC) AS rank
    FROM category_profit)

SELECT
category,
profit
FROM ranked_profit
WHERE rank = 1