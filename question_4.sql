CREATE VIEW store_summary_view
AS 
SELECT 
dim_store.store_type AS store_type,
SUM(orders.total_orders) AS total_sales,
ROUND(AVG(orders.total_orders)/(SUM(orders.total_orders)) * 100, 2) AS percentage_of_total_sales,
COUNT(orders.order_date_uuid) AS order_count
FROM orders
JOIN dim_store ON orders.store_code = dim_store.store_code
GROUP BY dim_store.store_type