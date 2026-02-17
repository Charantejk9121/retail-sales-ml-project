CREATE DATABASE IF NOT EXISTS retail_project;
USE retail_project;
DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail( -- creating table
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description TEXT,
    quantity INT,
    invoice_date VARCHAR(30),
    unit_price FLOAT,
    customer_id VARCHAR(20),
    country VARCHAR(50)
) CHARACTER SET latin1;


SET GLOBAL local_infile = 1; -- enabling to access local files 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/OnlineRetail.csv'
INTO TABLE online_retail
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT COUNT(*) FROM online_retail; -- noof rows
SET SQL_SAFE_UPDATES = 0;

-- removing rows with null customer_id
DELETE FROM online_retail
WHERE customer_id IS NULL;

-- creating revenue coulumn(reveneu = quantity * unit_price)
SELECT quantity * unit_price AS revenue
FROM online_retail
LIMIT 5;

-- total revenue
SELECT SUM(quantity * unit_price) AS total_revenue
FROM online_retail;

ALTER TABLE online_retail
ADD COLUMN  invoice_datetime DATETIME; -- ading new coulumn datetime
UPDATE online_retail -- converitng str to date format
SET invoice_datetime = STR_TO_DATE(invoice_date, '%m/%e/%Y %k:%i');

-- monthly sales trend
SELECT
	DATE_FORMAT(invoice_datetime, '%Y-%m') AS month,
    SUM(quantity * unit_price) AS momthly_revenue
FROM online_retail
GROUP BY DATE_FORMAT(invoice_datetime, '%Y-%m')
ORDER BY DATE_FORMAT(invoice_datetime, '%Y-%m');

-- Top 10 customers by revenue
SELECT
	customer_id,
    SUM(quantity * unit_price) AS total_spent
FROM online_retail
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Top 10 products
SELECT
	description,
    SUM(quantity) AS total_sold
FROM online_retail
GROUP BY description
ORDER BY total_sold DESC
LIMIT 10;

-- Country wise revenue
SELECT
	country,
    SUM(quantity * unit_price) AS revenue
FROM online_retail
GROUP BY country
ORDER BY revenue DESC;

-- CUSTOMER LIFETIME VALUE
SELECT
	customer_id,
    SUM(quantity * unit_price) AS lifetime_value
FROM online_retail
GROUP BY customer_id;

-- REPEAT CUSTOMERS
SELECT
	customer_id,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM online_retail
GROUP BY customer_id
HAVING COUNT(DISTINCT invoice_no) > 1;

-- RFM Preparation(Recency, frequency, monetary)
-- Recency
SELECT
	customer_id,
    MAX(invoice_date) AS last_purchase
FROM online_retail
GROUP BY customer_id;

-- Frequency
SELECT
	customer_id,
    COUNT(DISTINCT invoice_no) AS frequency
FROM online_retail
GROUP BY customer_id;

-- Monetary
SELECT
	customer_id,
    SUM(quantity * unit_price) AS monetary
FROM online_retail
GROUP BY customer_id;