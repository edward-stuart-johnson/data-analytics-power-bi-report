-- change dates in country-region table to date format
UPDATE country_region 
SET dates = CAST(dates AS DATE);

-- create a common table expression to calculate the total revenue grouped by month and year
WITH monthly_revenue AS (
    SELECT
    DATE_PART ('year', TIMESTAMP dates) AS sale_year,
    DATE_PART ('month', TIMESTAMP dates) AS sale_month,
    SUM(sale_price) AS revenue
    FROM country_region c
    GROUP BY sale_year,
    sale_month
    )

-- rank the monthly revenues in descending order
, ranked_revenue AS (
    SELECT
    sale_year,
    sale_month,
    revenue,
    RANK() OVER (ORDER BY revenue DESC)
    AS rank
    FROM monthly_revenue
)

-- filter to get only the highest revenue month in 2022
SELECT
    sale_year,
    sale_month,
    revenue
    FROM ranked_revenue
    WHERE sale_year = 2022
    AND rank = 1