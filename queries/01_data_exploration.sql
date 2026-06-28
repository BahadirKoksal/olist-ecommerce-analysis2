-- ================================================
-- OLIST E-COMMERCE ANALYSIS
-- 01: Data Exploration
-- ================================================

-- -----------------------------------------------
-- ROW COUNTS
-- -----------------------------------------------

SELECT COUNT(*) AS total_orders
FROM `Olist.olist_orders_dataset`;

SELECT COUNT(*) AS total_payments
FROM `Olist.olist_order_payments_dataset`;

SELECT COUNT(*) AS total_order_items
FROM `Olist.olist_order_items_dataset`;

SELECT COUNT(*) AS total_reviews
FROM `Olist.olist_order_reviews_dataset`;

SELECT COUNT(*) AS total_customers
FROM `Olist.olist_customers_dataset`;

SELECT COUNT(*) AS total_sellers
FROM `Olist.olist_sellers_dataset`;

SELECT COUNT(*) AS total_geolocations
FROM `Olist.olist_geolocation_dataset`;

-- -----------------------------------------------
-- SCHEMA INSPECTION
-- -----------------------------------------------

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_orders_dataset';

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_order_payments_dataset';

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_order_items_dataset';

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_order_reviews_dataset';

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_customers_dataset';

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_sellers_dataset';

SELECT column_name, data_type
FROM `project-f459b334-59af-4d62-803.Olist.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'olist_geolocation_dataset';

-- -----------------------------------------------
-- SAMPLE DATA
-- -----------------------------------------------

SELECT * FROM `Olist.olist_orders_dataset` LIMIT 10;
SELECT * FROM `Olist.olist_order_payments_dataset` LIMIT 10;
SELECT * FROM `Olist.olist_order_items_dataset` LIMIT 10;
SELECT * FROM `Olist.olist_order_reviews_dataset` LIMIT 10;
SELECT * FROM `Olist.olist_customers_dataset` LIMIT 10;
SELECT * FROM `Olist.olist_sellers_dataset` LIMIT 10;
SELECT * FROM `Olist.olist_geolocation_dataset` LIMIT 10;

-- -----------------------------------------------
-- UNIQUE ZIP CODES IN GEOLOCATION
-- -----------------------------------------------

SELECT COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_count
FROM `Olist.olist_geolocation_dataset`;

-- -----------------------------------------------
-- ORDER STATUS DISTRIBUTION
-- -----------------------------------------------

SELECT order_status, COUNT(*) AS count
FROM `Olist.olist_orders_dataset`
GROUP BY order_status
ORDER BY count DESC;
