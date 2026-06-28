-- ================================================
-- OLIST E-COMMERCE ANALYSIS
-- 02: Data Cleaning & Quality Checks
-- ================================================

-- -----------------------------------------------
-- olist_orders_dataset - NULL CHECK
-- -----------------------------------------------

SELECT 
  COUNTIF(order_id IS NULL) AS null_order_id,
  COUNTIF(customer_id IS NULL) AS null_customer_id,
  COUNTIF(order_status IS NULL) AS null_status,
  COUNTIF(order_delivered_customer_date IS NULL) AS null_delivery_date,
  COUNTIF(order_estimated_delivery_date IS NULL) AS null_estimated_date
FROM `Olist.olist_orders_dataset`;

-- Check which order statuses have NULL delivery dates
SELECT order_status, COUNT(*) AS count
FROM `Olist.olist_orders_dataset`
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY count DESC;

-- -----------------------------------------------
-- olist_order_payments_dataset - NULL CHECK
-- -----------------------------------------------

SELECT
  COUNTIF(order_id IS NULL) AS null_order_id,
  COUNTIF(payment_type IS NULL) AS null_payment_type,
  COUNTIF(payment_value IS NULL) AS null_payment_value,
  COUNTIF(payment_value = 0) AS zero_payment_value
FROM `Olist.olist_order_payments_dataset`;

-- Inspect zero payment value records
SELECT *
FROM `Olist.olist_order_payments_dataset`
WHERE payment_value = 0;

-- -----------------------------------------------
-- olist_order_items_dataset - NULL CHECK
-- -----------------------------------------------

SELECT
  COUNTIF(order_id IS NULL) AS null_order_id,
  COUNTIF(product_id IS NULL) AS null_product_id,
  COUNTIF(seller_id IS NULL) AS null_seller_id,
  COUNTIF(price IS NULL) AS null_price,
  COUNTIF(freight_value IS NULL) AS null_freight,
  COUNTIF(price = 0) AS zero_price,
  COUNTIF(freight_value = 0) AS zero_freight
FROM `Olist.olist_order_items_dataset`;

-- Inspect zero freight records
SELECT 
  COUNT(*) AS count,
  AVG(price) AS avg_price,
  MIN(price) AS min_price,
  MAX(price) AS max_price
FROM `Olist.olist_order_items_dataset`
WHERE freight_value = 0;

-- -----------------------------------------------
-- olist_order_reviews_dataset - NULL CHECK
-- -----------------------------------------------

SELECT
  COUNTIF(review_id IS NULL) AS null_review_id,
  COUNTIF(order_id IS NULL) AS null_order_id,
  COUNTIF(review_score IS NULL) AS null_score,
  COUNTIF(review_score NOT IN (1,2,3,4,5)) AS invalid_score
FROM `Olist.olist_order_reviews_dataset`;

-- -----------------------------------------------
-- olist_customers_dataset - NULL CHECK
-- -----------------------------------------------

SELECT
  COUNTIF(customer_id IS NULL) AS null_customer_id,
  COUNTIF(customer_unique_id IS NULL) AS null_unique_id,
  COUNTIF(customer_city IS NULL) AS null_city,
  COUNTIF(customer_state IS NULL) AS null_state,
  COUNTIF(customer_zip_code_prefix IS NULL) AS null_zip
FROM `Olist.olist_customers_dataset`;

-- -----------------------------------------------
-- olist_sellers_dataset - NULL CHECK
-- -----------------------------------------------

SELECT
  COUNTIF(seller_id IS NULL) AS null_seller_id,
  COUNTIF(seller_city IS NULL) AS null_city,
  COUNTIF(seller_state IS NULL) AS null_state,
  COUNTIF(seller_zip_code_prefix IS NULL) AS null_zip
FROM `Olist.olist_sellers_dataset`;

-- -----------------------------------------------
-- olist_geolocation_dataset - NULL CHECK
-- -----------------------------------------------

SELECT
  COUNTIF(geolocation_zip_code_prefix IS NULL) AS null_zip,
  COUNTIF(geolocation_lat IS NULL) AS null_lat,
  COUNTIF(geolocation_lng IS NULL) AS null_lng,
  COUNTIF(geolocation_city IS NULL) AS null_city,
  COUNTIF(geolocation_state IS NULL) AS null_state
FROM `Olist.olist_geolocation_dataset`;

-- Unique ZIP codes vs total rows
SELECT COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_count
FROM `Olist.olist_geolocation_dataset`;

-- -----------------------------------------------
-- CLEANING SUMMARY
-- -----------------------------------------------

-- Decision 1: Filter delivered orders with NULL delivery date (8 records)
-- Decision 2: Filter not_defined payment type with zero value (3 records)
-- Decision 3: Keep zero freight records (383 records - free shipping campaigns)
-- Decision 4: Use AVG lat/lng per ZIP code for geolocation joins

-- Clean delivered orders (used in all subsequent analysis)
SELECT *
FROM `Olist.olist_orders_dataset`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- Clean payments (used in all subsequent analysis)
SELECT *
FROM `Olist.olist_order_payments_dataset`
WHERE payment_type != 'not_defined'
  AND payment_value > 0;

-- Clean geolocation (single coordinate per ZIP)
SELECT 
  geolocation_zip_code_prefix,
  AVG(geolocation_lat) AS lat,
  AVG(geolocation_lng) AS lng,
  MAX(geolocation_state) AS state,
  MAX(geolocation_city) AS city
FROM `Olist.olist_geolocation_dataset`
GROUP BY geolocation_zip_code_prefix;
