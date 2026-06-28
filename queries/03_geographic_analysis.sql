-- ================================================
-- OLIST E-COMMERCE ANALYSIS
-- 03: Geographic Insights
-- ================================================

-- -----------------------------------------------
-- STEP 1: REVENUE DISTRIBUTION BY STATE
-- -----------------------------------------------

SELECT 
  c.customer_state AS state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  ROUND(AVG(p.payment_value), 2) AS avg_order_value
FROM `Olist.olist_orders_dataset` o
JOIN `Olist.olist_customers_dataset` c 
  ON o.customer_id = c.customer_id
JOIN `Olist.olist_order_payments_dataset` p 
  ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type != 'not_defined'
GROUP BY state
ORDER BY total_revenue DESC;

-- -----------------------------------------------
-- STEP 2: CUSTOMER DENSITY BY STATE
-- -----------------------------------------------

SELECT 
  c.customer_state AS state,
  COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
  COUNT(DISTINCT c.customer_id) AS total_customer_records,
  COUNT(DISTINCT c.customer_id) - COUNT(DISTINCT c.customer_unique_id) AS repeat_customers
FROM `Olist.olist_customers_dataset` c
GROUP BY state
ORDER BY unique_customers DESC;

-- -----------------------------------------------
-- STEP 3: SELLER DISTRIBUTION & CUSTOMER/SELLER RATIO
-- -----------------------------------------------

SELECT 
  s.seller_state AS state,
  COUNT(DISTINCT s.seller_id) AS total_sellers,
  COUNT(DISTINCT c.customer_unique_id) AS total_customers,
  ROUND(COUNT(DISTINCT c.customer_unique_id) / NULLIF(COUNT(DISTINCT s.seller_id), 0), 1) AS customers_per_seller
FROM `Olist.olist_sellers_dataset` s
FULL OUTER JOIN `Olist.olist_order_items_dataset` oi 
  ON s.seller_id = oi.seller_id
FULL OUTER JOIN `Olist.olist_orders_dataset` o 
  ON oi.order_id = o.order_id
FULL OUTER JOIN `Olist.olist_customers_dataset` c 
  ON o.customer_id = c.customer_id
GROUP BY state
ORDER BY total_sellers DESC;

-- -----------------------------------------------
-- STEP 4: CUSTOMER SATISFACTION BY STATE
-- -----------------------------------------------

SELECT 
  c.customer_state AS state,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(r.review_id) AS total_reviews,
  COUNTIF(r.review_score = 5) AS five_star,
  COUNTIF(r.review_score = 1) AS one_star,
  ROUND(COUNTIF(r.review_score = 5) / COUNT(r.review_id) * 100, 1) AS five_star_pct,
  ROUND(COUNTIF(r.review_score = 1) / COUNT(r.review_id) * 100, 1) AS one_star_pct
FROM `Olist.olist_orders_dataset` o
JOIN `Olist.olist_customers_dataset` c 
  ON o.customer_id = c.customer_id
JOIN `Olist.olist_order_reviews_dataset` r 
  ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY avg_review_score ASC;

-- -----------------------------------------------
-- STEP 5: DELIVERY PERFORMANCE BY STATE
-- -----------------------------------------------

SELECT 
  c.customer_state AS state,
  ROUND(AVG(DATE_DIFF(o.order_delivered_customer_date, 
    o.order_purchase_timestamp, DAY)), 1) AS avg_delivery_days,
  ROUND(AVG(DATE_DIFF(o.order_estimated_delivery_date, 
    o.order_purchase_timestamp, DAY)), 1) AS avg_estimated_days,
  ROUND(AVG(DATE_DIFF(o.order_delivered_customer_date, 
    o.order_estimated_delivery_date, DAY)), 1) AS avg_delay_days,
  COUNTIF(o.order_delivered_customer_date > o.order_estimated_delivery_date) AS late_deliveries,
  COUNT(o.order_id) AS total_orders,
  ROUND(COUNTIF(o.order_delivered_customer_date > o.order_estimated_delivery_date) 
    / COUNT(o.order_id) * 100, 1) AS late_delivery_pct
FROM `Olist.olist_orders_dataset` o
JOIN `Olist.olist_customers_dataset` c 
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY state
ORDER BY avg_delivery_days DESC;

-- -----------------------------------------------
-- STEP 6: COMBINED REGIONAL PERFORMANCE
-- (Revenue + Delivery + Satisfaction in one query)
-- -----------------------------------------------

SELECT 
  c.customer_state AS state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  ROUND(AVG(p.payment_value), 2) AS avg_order_value,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(AVG(DATE_DIFF(o.order_delivered_customer_date, 
    o.order_purchase_timestamp, DAY)), 1) AS avg_delivery_days,
  ROUND(COUNTIF(o.order_delivered_customer_date > o.order_estimated_delivery_date) 
    / COUNT(o.order_id) * 100, 1) AS late_delivery_pct,
  COUNT(DISTINCT s.seller_id) AS total_sellers,
  ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS revenue_per_order
FROM `Olist.olist_orders_dataset` o
JOIN `Olist.olist_customers_dataset` c ON o.customer_id = c.customer_id
JOIN `Olist.olist_order_payments_dataset` p ON o.order_id = p.order_id
JOIN `Olist.olist_order_reviews_dataset` r ON o.order_id = r.order_id
JOIN `Olist.olist_order_items_dataset` oi ON o.order_id = oi.order_id
JOIN `Olist.olist_sellers_dataset` s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND p.payment_type != 'not_defined'
GROUP BY state
ORDER BY total_revenue DESC;
