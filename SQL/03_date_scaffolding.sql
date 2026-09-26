--===== DATE SCAFFOLDING =====--

-- date scaffolding for tableau monthly revenue chart --
CREATE TABLE country_month_sales AS
WITH countries AS (
    SELECT DISTINCT country
    FROM online_retail_cleaned
),
months AS (
    SELECT generate_series('2010-12-01'::date,'2011-12-01'::date,'1 month'::interval)::date AS month
),
country_months AS (
    SELECT
        c.country,
        m.month
    FROM countries c
    CROSS JOIN months m
),
monthly_revenue AS (
    SELECT
        country,
        DATE_TRUNC('month', invoice_date)::date AS month,
        SUM(quantity * unit_price) AS revenue
    FROM online_retail_cleaned
    GROUP BY country, DATE_TRUNC('month', invoice_date)::date
)
SELECT
    cm.country,
    cm.month,
    COALESCE(mr.revenue, 0) AS revenue
FROM country_months cm
LEFT JOIN monthly_revenue mr
    ON cm.country = mr.country
    AND cm.month = mr.month
ORDER BY cm.country, cm.month;
