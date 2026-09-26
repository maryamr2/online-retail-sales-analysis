--===== DATA EXPLORATION =====--

-- row count --
SELECT 
	COUNT(*)
FROM online_retail AS row_count;

-- dates involved --
SELECT 
	MIN(invoice_date) AS earliest_date,
	MAX(invoice_date) AS latest_date
FROM online_retail;

-- missing values --
SELECT
    COUNT(invoice_no) AS invoice_numbers,
    COUNT(stock_code) AS stock_codes,
    COUNT(description) AS descriptions,
    COUNT(quantity) AS quantities,
    COUNT(invoice_date) AS invoice_dates,
    COUNT(unit_price) AS unit_prices,
    COUNT(customer_id) AS customer_ids,
    COUNT(country) AS countries
FROM online_retail;

-- unique values --
SELECT 
	COUNT(DISTINCT invoice_no) AS number_of_invoices,
	COUNT(DISTINCT stock_code) AS number_of_products,
	COUNT(DISTINCT customer_id) AS number_of_customers,
	COUNT(DISTINCT country) AS number_of_countries
FROM online_retail;

-- non-product related transactions/fees --
SELECT
    SUM(CASE 
            WHEN stock_code IN ('DOT', 'POST', 'C2') 
            THEN quantity * unit_price 
            ELSE 0 
        END) AS postage_revenue,
    SUM(CASE 
            WHEN stock_code = 'M' 
            THEN quantity * unit_price 
            ELSE 0 
        END) AS manual_transactions,
    SUM(CASE 
            WHEN stock_code = 'B' 
            THEN quantity * unit_price 
            ELSE 0 
        END) AS bad_debt,
    SUM(CASE 
            WHEN stock_code = 'AMAZONFEE' 
            THEN quantity * unit_price 
            ELSE 0 
        END) AS amazon_fee
FROM online_retail;

--===== DATA CLEANING =====--

-- completed sales only --
CREATE TABLE online_retail_cleaned AS 
SELECT *
FROM online_retail 
WHERE invoice_no NOT LIKE 'C%' 
	AND unit_price > 0 
	AND quantity > 0
	AND stock_code NOT IN ('DOT','M','B','POST','AMAZONFEE','C2');