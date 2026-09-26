--===== SALES ANALYSIS =====--

-- revenue from product sales --
SELECT 
	SUM(quantity*unit_price) AS revenue
FROM online_retail_cleaned;

-- quantity of items sold --
SELECT 
	SUM(quantity)
FROM online_retail_cleaned;
	
-- average order value --
WITH order_values AS
(SELECT 
	invoice_no, SUM(quantity*unit_price) AS order_value
FROM online_retail_cleaned
GROUP BY invoice_no)
SELECT ROUND(AVG(order_value),2) AS avg_order_value
FROM order_values;

-- monthly revenue growth --
WITH monthly_sales AS (
SELECT 
	TO_CHAR(invoice_date,'YYYY-MM') AS month,
	SUM(quantity*unit_price) AS revenue,
	COUNT(DISTINCT invoice_no) AS orders,
	SUM(quantity) AS quantity
FROM online_retail_cleaned
GROUP BY month
),
monthly_sales2 AS (
SELECT
	*,
	ROUND(revenue/orders,2) AS monthly_aov,
	LAG(revenue) OVER(ORDER BY month) AS prev_month_revenue
FROM monthly_sales
ORDER BY month
)
SELECT 
	month,
	revenue,
	orders,
	quantity,
	monthly_aov,
	ROUND(100*(revenue-prev_month_revenue)/prev_month_revenue,1) AS monthly_rev_growth
FROM monthly_sales2;

--===== PRODUCT ANALYSIS =====--

-- top 10 products by revenue --
SELECT 
	stock_code, 
	description,
	SUM(quantity*unit_price) AS revenue
FROM online_retail_cleaned
GROUP BY stock_code, description
ORDER BY revenue DESC
LIMIT 10;

-- top 10 products by quantity sold --
SELECT 
	stock_code, 
	description,
	SUM(quantity) AS quantity
FROM online_retail_cleaned
GROUP BY stock_code, description
ORDER BY quantity DESC
LIMIT 10;

-- highest-volume and highest-revenue products --
WITH product_data AS (
SELECT
	stock_code, 
	SUM(quantity) AS quantity, 
	SUM(quantity*unit_price) AS revenue,
	DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS rank_quantity,
	DENSE_RANK() OVER(ORDER BY SUM(quantity*unit_price) DESC) AS rank_revenue
FROM online_retail_cleaned
GROUP BY stock_code
)
SELECT * 
FROM product_data
WHERE rank_quantity <= 10 
	AND rank_revenue <= 10;

--===== TRENDS BY COUNTRY =====--

SELECT
	country, 
	SUM(quantity*unit_price) AS revenue,
	COUNT(DISTINCT invoice_no) AS no_of_orders,
	ROUND(SUM(quantity*unit_price)/COUNT(DISTINCT invoice_no),2) AS aov,
	SUM(quantity) AS quantity_sold,
	COUNT(DISTINCT customer_id) AS no_of_customers,
	ROUND(SUM(quantity*unit_price)/NULLIF(COUNT(DISTINCT customer_id),0),2) AS revenue_per_customer,
	ROUND(100.0*SUM(quantity*unit_price)/SUM(SUM(quantity*unit_price)) OVER (),2) AS revenue_contribution
FROM online_retail_sales
GROUP BY country
ORDER BY revenue DESC
