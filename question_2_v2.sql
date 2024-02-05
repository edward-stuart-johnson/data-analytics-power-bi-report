-- change dates in country-region table to date format
UPDATE country_region 
SET dates = CAST(dates AS DATETIME);

SELECT
EXTRACT(YEAR FROM TIMESTAMP c.dates) AS sale_year,
EXTRACT(MONTH FROM TIMESTAMP c.dates) AS sale_month,
SUM(c.sale_price) AS revenue
FROM country_region c
GROUP BY sale_year,
sale_month
ORDER BY revenue DESC
