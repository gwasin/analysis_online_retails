CREATE TABLE online_retails
		(
			invoice_stockCode VARCHAR,
			stock_code VARCHAR,
			description	VARCHAR,
			quantity VARCHAR,
			invoice_date VARCHAR,
			unit_price NUMERIC(10, 2),	
			customer_id FLOAT,
			country VARCHAR
		);

-- select all

SELECT * FROM online_retails

-- totals sales

SELECT SUM(unit_price) as total_sales
FROM online_retails;

-- avg sales

SELECT ROUND(AVG(unit_price), 2) as avg_sales
FROM online_retails;

-- sales per customer_id

SELECT customer_id,
	   SUM(quantity * unit_price)
FROM online_retails
GROUP BY 1

-- Recency Frequency Monetary

ALTER TABLE online_retails
ADD COLUMN converted_timestamp TIMESTAMP;


ALTER TABLE online_retails
ALTER COLUMN quantity TYPE INTEGER
USING quantity::INTEGER;

UPDATE online_retails
SET converted_timestamp = TO_TIMESTAMP(invoice_date, 'DD/MM/YYYY HH24:MI');

WITH sales AS (
	SELECT 
		customer_id,
		TO_TIMESTAMP(invoice_date, 'DD/MM/YYYY HH24:MI') as invoice_ts,
		invoice_stockcode as invoice_no,
		quantity * unit_price as total_amount
	 FROM online_retails
	 WHERE customer_id IS NOT NULL
),
last_purchase_date AS (
SELECT MAX(invoice_ts) as max_invoice_ts
FROM sales
),
rfm_raw AS (
	SELECT 
		customer_id,
		DATE_PART('d', (SELECT max_invoice_ts FROM last_purchase_date) - MAX(invoice_ts)) AS recency,
		COUNT(DISTINCT invoice_no) AS frequency,
		SUM(total_amount) AS monetary
    FROM sales
    GROUP BY customer_id
)
SELECT * FROM rfm_raw;

-- country per price

SELECT country,
	   SUM(quantity * unit_price) as total_sales
FROM online_retails
GROUP BY 1
ORDER BY total_sales DESC;
 
