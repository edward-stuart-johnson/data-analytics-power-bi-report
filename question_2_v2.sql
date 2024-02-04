-- change dates in country-region table to date format
UPDATE country_region 
SET dates = CAST(dates AS date);

SELECT
DATE_PART ('year', TIMESTAMP dates) AS sale_year,
DATE_PART ('month', TIMESTAMP dates) AS sale_month,
SUM(sale_price) AS revenue
FROM country_region
GROUP BY sale_year,
sale_month
ORDER BY revenue DESC
