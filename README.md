# 🛒 Olist E-Commerce Data Analysis & Business Insights

## 📌 Project Summary

This project presents a comprehensive analysis of the **Olist Brazilian E-Commerce Dataset** using **Google BigQuery SQL**. Olist is a Brazilian marketplace platform that connects sellers to customers across multiple channels. The dataset covers real-world e-commerce transactions from **2016 to 2018**, containing over 100,000 orders across 27 Brazilian states.

The analysis focuses on two core business areas:
- 🗺️ **Geographic Insights** — Regional revenue distribution, delivery performance, and customer satisfaction by state
- 📊 **Business Performance Metrics** — Financial KPIs, payment behavior, customer retention, and seller performance

> *"Where is Olist making money, and where is it losing it?"*

---

## 🎯 Business Questions

### Geographic Insights
- Which states generate the most revenue and orders?
- How are customers and sellers distributed across Brazil?
- Which regions have the longest delivery times?
- Is there a correlation between delivery performance and customer satisfaction?
- Which states have the highest late delivery rates?

### Business Performance Metrics
- What are Olist's core financial KPIs (Revenue, AOV, CLV)?
- How has revenue grown over time? Is there seasonality?
- What payment methods do customers prefer?
- How many customers return for a second purchase?
- Which sellers generate the most revenue and how satisfied are their customers?

---

## 🗂️ Dataset

The dataset is publicly available on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and was loaded into **Google BigQuery** for SQL-based analysis.

It contains **9 interconnected tables**:

| Table | Rows | Description |
|---|---|---|
| `olist_orders_dataset` | 99,441 | Core order table — status, timestamps |
| `olist_order_items_dataset` | 112,650 | Products per order — price, freight |
| `olist_order_payments_dataset` | 103,886 | Payment type, installments, value |
| `olist_order_reviews_dataset` | 99,224 | Customer review scores and comments |
| `olist_customers_dataset` | 99,441 | Customer city, state, unique ID |
| `olist_sellers_dataset` | 3,095 | Seller location information |
| `olist_geolocation_dataset` | 1,000,163 | ZIP code coordinates |
| `olist_products_dataset` | — | Product category and dimensions |
| `olist_product_category_name_translation` | — | Portuguese to English category names |

### Key Relationships (ERD)
- `Orders` → `Order Items` : One-to-Many via `order_id`
- `Order Items` → `Products` : Many-to-One via `product_id`
- `Orders` → `Reviews` : One-to-One/Many via `order_id`
- `Orders` → `Payments` : One-to-Many via `order_id`
- `Customers` ↔ `Sellers` : Many-to-Many via `Orders`

---

## 🧹 Data Cleaning

| Table | Issue | Decision |
|---|---|---|
| `olist_orders_dataset` | 2,965 NULL delivery dates | Kept — non-delivered orders (canceled, shipped, etc.) |
| `olist_orders_dataset` | 8 "delivered" orders with NULL delivery date | Filtered with `WHERE order_delivered_customer_date IS NOT NULL` |
| `olist_order_payments_dataset` | 3 records with `payment_type = 'not_defined'` and `payment_value = 0` | Filtered with `WHERE payment_type != 'not_defined'` |
| `olist_order_items_dataset` | 383 records with `freight_value = 0` | Kept — likely free shipping campaigns |
| `olist_geolocation_dataset` | ~52 rows per ZIP code | Used `AVG(lat/lng) GROUP BY zip_code` for single coordinate per ZIP |

---

## 🔍 Analysis & Key Findings

### 🗺️ Geographic Insights

#### Revenue Distribution by State
- 🏆 **SP (São Paulo)** leads with 40,500 orders and **5.77M BRL** revenue — ~45% of all orders
- **RJ, MG** follow with 2M BRL and 1.8M BRL respectively
- **Bottom states** (AC, AP, RR) generate under 20K BRL but have the **highest AOV** (220–235 BRL)
- SP's low AOV (136 BRL) shows a high-volume, lower-ticket strategy

#### Customer & Seller Distribution
- SP has 40,302 unique customers and 1,849 sellers
- **MA has only 1 seller serving 388 customers** — critical gap, major growth opportunity
- PE, PI, CE show similar seller-customer imbalances

#### Delivery Performance
- 🐢 **RR** has the longest avg delivery: **29 days**
- ⚡ **SP** is fastest: **~8.3 days**
- 🚨 **AL has the highest late delivery rate: 23.8%**
- MA (19.7%), PI (16%), CE (15.3%) also critically high

#### Customer Satisfaction
- Lowest: **MA (3.84), AL (3.84), SE (3.91)**
- Highest: **SP (4.25), PR (4.24)**
- **Strong correlation confirmed** — states with longest delivery times have lowest review scores

---

### 📊 Business Performance Metrics

#### Overall Financial Summary

| Metric | Value |
|---|---|
| Total Orders | 96,477 |
| Total Unique Customers | 93,357 |
| Total Revenue | 19,776,160 BRL |
| Average Order Value (AOV) | 171.91 BRL |
| Total Product Revenue | 13,813,828 BRL |
| Total Freight Revenue | 2,300,190 BRL |
| Freight as % of Revenue | 11.6% |

#### Revenue Growth Over Time
- **Oct 2016:** 265 orders — platform launch
- **Nov 2017:** 7,289 orders — **Black Friday peak**
- **2018 average:** ~6,500 orders/month — growth plateau
- **Overall: ~26x growth in 2 years**
- AOV stable at 136–165 BRL — growth is volume-driven

#### Payment Behavior

| Payment Type | Share | Avg Value | Avg Installments |
|---|---|---|---|
| Credit Card | 73.9% | 163.32 BRL | 3.5 |
| Boleto | 19.0% | 145.03 BRL | 1.0 |
| Voucher | 5.6% | 65.70 BRL | 1.0 |
| Debit Card | 1.5% | 142.57 BRL | 1.0 |

#### Customer Retention

| Purchase Frequency | Customers | % |
|---|---|---|
| 1 time | 90,557 | 97.0% |
| 2 times | 2,573 | 2.8% |
| 3+ times | 229 | 0.2% |

| Customer Type | Count | Avg Revenue |
|---|---|---|
| New Customer | 90,556 | 160.76 BRL |
| Returning Customer | 2,801 | 308.59 BRL |

- 🚨 **97% of customers purchase only once**
- Returning customers spend **2x more** (308 BRL vs 161 BRL)

#### Top Seller Insights
- Top seller: **507,744 BRL** revenue, 967 orders — review score only **3.4**
- Most efficient seller (BA): **277,690 BRL** with 346 orders — AOV of **653 BRL**
- High revenue ≠ high satisfaction

---

## 💡 Business Recommendations

**1. Fix the North & Northeast Delivery Problem**
AL, MA, SE have 20%+ late delivery rates and below 3.9 review scores. Partner with regional logistics providers or open fulfillment centers in these states.

**2. Recruit Sellers in Underserved Regions**
MA has 1 seller for 388 customers. Targeted seller recruitment in MA, PE, PI could unlock significant untapped revenue.

**3. Invest in Customer Retention**
With 97% single-purchase rate, implement a loyalty program, email re-engagement, or personalized recommendations. Moving retention from 3% to 5% would significantly impact LTV.

**4. Leverage High-AOV States**
PB (284 BRL AOV), AC (264 BRL), AL (242 BRL) have small but high-spending customer bases. Targeted marketing here could yield high-value customers at lower acquisition cost.

**5. Monitor High-Revenue, Low-Satisfaction Sellers**
Top revenue sellers with scores below 3.5 are a reputational risk. Implement seller quality thresholds.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| Google BigQuery | Data storage and SQL analysis |
| SQL (Standard SQL) | Data cleaning, exploration, KPI calculation |


---
