-- ================================================
-- OLIST E-COMMERCE ANALYSIS
-- 04: Business Performance Metrics
-- ================================================

-- -----------------------------------------------
-- STEP 1: OVERALL FINANCIAL SUMMARY
-- -----------------------------------------------

SELECT 
  COUNT(DISTINCT o.order_id) AS total_orders,
  COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  ROUND(AVG(p.payment_value), 2) AS avg_order_value,
  ROUND(SUM(i.freight_value), 2) AS total_freight_revenue,
  ROUND(SUM(i.price), 2) AS total_product_revenue,
  ROUND(SUM(i.freight_value) / SUM(p.payment_value) * 100, 1) AS freight_revenue_pct
FROM `Olist.olist_orders_dataset` o
JOIN `Olist.olist_customers_dataset` c 
  ON o.customer_id = c.customer_id
JOIN `Olist.olist_order_payments_dataset` p 
  ON o.order_id = p.order_id
JOIN `Olist.olist_order_items_dataset` i 
  ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type != 'not_defined';

-- -----------------------------------------------
-- STEP 2: MONTHLY REVENUE TRENDS
-- -----------------------------------------------

SELECT 
  FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS year_month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  ROUND(AVG(p.payment_value), 2) AS avg_order_value,
  COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM `Olist.olist_orders_dataset` o
JOIN `Olist.olist_customers_dataset` c 
  ON o.customer_id = c.customer_id
JOIN `Olist.olist_order_payments_dataset` p 
  ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type != 'not_defined'
GROUP BY year_month
ORDER BY year_month ASC;

-- -----------------------------------------------
-- STEP 3: PAYMENT BEHAVIOR ANALYSIS
-- -----------------------------------------------

SELECT 
  payment_type,
  COUNT(*) AS total_transactions,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 1) AS transaction_pct,
  ROUND(SUM(payment_value), 2) AS total_revenue,
  ROUND(AVG(payment_value), 2) AS avg_payment_value,
  ROUND(AVG(payment_installments), 1) AS avg_installments,
  MAX(payment_installments) AS max_installments
FROM `Olist.olist_order_payments_dataset`
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY total_transactions DESC;

-- -----------------------------------------------
-- STEP 4A: CUSTOMER RETENTION - PURCHASE FREQUENCY
-- -----------------------------------------------

SELECT 
  purchase_count,
  COUNT(*) AS customer_count,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 1) AS pct
FROM (
  SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS purchase_count
  FROM `Olist.olist_customers_dataset` c
  JOIN `Olist.olist_orders_dataset` o 
    ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
GROUP BY purchase_count
ORDER BY purchase_count ASC;

-- -----------------------------------------------
-- STEP 4B: NEW VS RETURNING CUSTOMER REVENUE
-- -----------------------------------------------

SELECT 
  CASE 
    WHEN purchase_count = 1 THEN 'new_customer'
    ELSE 'returning_customer'
  END AS customer_type,
  COUNT(*) AS customer_count,
  ROUND(AVG(total_spent), 2) AS avg_revenue_per_customer
FROM (
  SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS purchase_count,
    SUM(p.payment_value) AS total_spent
  FROM `Olist.olist_customers_dataset` c
  JOIN `Olist.olist_orders_dataset` o 
    ON c.customer_id = o.customer_id
  JOIN `Olist.olist_order_payments_dataset` p 
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
    AND p.payment_type != 'not_defined'
  GROUP BY c.customer_unique_id
)
GROUP BY customer_type
ORDER BY customer_type;

-- -----------------------------------------------
-- STEP 5: TOP 20 SELLER PERFORMANCE
-- -----------------------------------------------

SELECT 
  s.seller_id,
  s.seller_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  ROUND(AVG(p.payment_value), 2) AS avg_order_value,
  ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM `Olist.olist_sellers_dataset` s
JOIN `Olist.olist_order_items_dataset` oi 
  ON s.seller_id = oi.seller_id
JOIN `Olist.olist_orders_dataset` o 
  ON oi.order_id = o.order_id
JOIN `Olist.olist_order_payments_dataset` p 
  ON o.order_id = p.order_id
JOIN `Olist.olist_order_reviews_dataset` r 
  ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type != 'not_defined'
GROUP BY s.seller_id, s.seller_state
ORDER BY total_revenue DESC
LIMIT 20;

-- -----------------------------------------------
-- STEP 6: OVERALL SELLER PERFORMANCE SUMMARY
-- -----------------------------------------------

SELECT 
  COUNT(DISTINCT s.seller_id) AS total_active_sellers,
  ROUND(AVG(seller_revenue), 2) AS avg_revenue_per_seller,
  ROUND(AVG(seller_orders), 1) AS avg_orders_per_seller,
  ROUND(AVG(seller_review), 2) AS avg_review_score
FROM (
  SELECT 
    s.seller_id,
    SUM(p.payment_value) AS seller_revenue,
    COUNT(DISTINCT o.order_id) AS seller_orders,
    AVG(r.review_score) AS seller_review
  FROM `Olist.olist_sellers_dataset` s
  JOIN `Olist.olist_order_items_dataset` oi 
    ON s.seller_id = oi.seller_id
  JOIN `Olist.olist_orders_dataset` o 
    ON oi.order_id = o.order_id
  JOIN `Olist.olist_order_payments_dataset` p 
    ON o.order_id = p.order_id
  JOIN `Olist.olist_order_reviews_dataset` r 
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND p.payment_type != 'not_defined'
  GROUP BY s.seller_id
);
