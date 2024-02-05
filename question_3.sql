
-- change dates in country-region table to date format
UPDATE country_region 
SET dates = CAST(dates AS DATE);

-- create a common table expression to calculate the total revenue grouped by month and year
WITH revenue AS (
    SELECT
    store_type,
    DATE_PART('year', TIMESTAMP dates) AS sale_year,
    SUM(sale_price) AS revenue
    FROM dim_store
    WHERE country = 'Germany'
    GROUP BY DATE_PART(YEAR, TIMESTAMP dates)
    )

-- rank the yearly revenues in descending order
, ranked_revenue AS (
    SELECT
    store_type,
    sale_year,
    revenue,
    RANK() OVER (ORDER BY revenue DESC)
    AS rank
    FROM revenue
)

-- filter to get only the highest revenue store_type in 2022
SELECT
    store_type,
    sale_year,
    revenue
    FROM ranked_revenue
    WHERE sale_year = 2022
    AND rank = 1