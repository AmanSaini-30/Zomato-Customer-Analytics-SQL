 -- ZOMATO CUSTOMER ANALYTICS — SQL PROJECT
 -- Author: Data Analyst
    
create database Zomato_Analyst;
use Zomato_Analyst;
 

-- DROP TABLE IF EXISTS fact_orders;
-- DROP TABLE IF EXISTS dim_restaurant;
-- DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
    customer_id           VARCHAR(10) PRIMARY KEY,
    customer_name         VARCHAR(100),
    city                  VARCHAR(50),
    signup_time           DATETIME,
    acquisition_channel   VARCHAR(50)
);

select * from dim_customer;

CREATE TABLE dim_restaurant (
    restaurant_id         VARCHAR(10) PRIMARY KEY,
    restaurant_name       VARCHAR(100),
    cuisine               VARCHAR(50),
    city                  VARCHAR(50),
    avg_rating            DECIMAL(2,1)
);

select * from dim_restaurant;

CREATE TABLE fact_orders (
    order_id              VARCHAR(10) PRIMARY KEY,
    customer_id           VARCHAR(10),
    restaurant_id         VARCHAR(10),
    order_timestamp       DATETIME,
    order_amount          DECIMAL(10,2),
    discount_amount       DECIMAL(10,2),
    delivery_fee          DECIMAL(10,2),
    payment_mode          VARCHAR(20),
    order_status          VARCHAR(20),      -- Delivered / Cancelled / Refunded
    FOREIGN KEY (customer_id)   REFERENCES dim_customer(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id)
);

 
 select * from fact_orders;


-- REVENUE ANALYSIS
 
-- 1.1 Total revenue
SELECT ROUND(SUM(order_amount - discount_amount), 2) AS total_revenue
FROM fact_orders
WHERE order_status = 'Delivered';

-- 1.2 Monthly revenue trend
SELECT
    DATE_FORMAT(order_timestamp, '%Y-%m') AS month,      -- Postgres: TO_CHAR(order_timestamp,'YYYY-MM')
    ROUND(SUM(order_amount - discount_amount), 2) AS revenue,
    COUNT(*) AS delivered_orders
FROM fact_orders
WHERE order_status = 'Delivered'
GROUP BY 1
ORDER BY 1;

-- 1.3 Revenue by city (highest-contributing city)
SELECT
    c.city,
    ROUND(SUM(o.order_amount - o.discount_amount), 2) AS revenue,
    COUNT(*) AS delivered_orders
FROM fact_orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city
ORDER BY revenue DESC;

-- 1.4 Revenue by payment mode
SELECT
    payment_mode,
    ROUND(SUM(order_amount - discount_amount), 2) AS revenue,
    COUNT(*) AS delivered_orders
FROM fact_orders
WHERE order_status = 'Delivered'
GROUP BY payment_mode
ORDER BY revenue DESC;

-- 1.5 Average Order Value (AOV)
SELECT ROUND(AVG(order_amount), 2) AS avg_order_value
FROM fact_orders
WHERE order_status = 'Delivered';

 
-- CUSTOMER ANALYSIS
  
-- 2.1 Top 20 customers by revenue
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    ROUND(SUM(o.order_amount - o.discount_amount), 2) AS customer_revenue,
    COUNT(*) AS total_orders
FROM fact_orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY customer_revenue DESC
LIMIT 20;

-- 2.2 % of revenue from top 20 customers (Pareto check)
WITH cust_rev AS (
    SELECT customer_id, SUM(order_amount - discount_amount) AS rev
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY rev DESC) AS rn
    FROM cust_rev
)
SELECT
    ROUND(SUM(CASE WHEN rn <= 20 THEN rev ELSE 0 END), 2)               AS top20_revenue,
    ROUND(SUM(rev), 2)                                                   AS total_revenue,
    ROUND(100.0 * SUM(CASE WHEN rn <= 20 THEN rev ELSE 0 END) / SUM(rev), 2) AS pct_from_top20
FROM ranked;

-- 2.3 Highest-value acquisition channel (avg & total revenue per channel)
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_amount - o.discount_amount), 2) AS total_revenue,
    ROUND(SUM(o.order_amount - o.discount_amount) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM dim_customer c
LEFT JOIN fact_orders o ON o.customer_id = c.customer_id AND o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;

-- 2.4 Repeat customers (customers with 2+ delivered orders) vs one-time
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS orders
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN orders = 1 THEN 1 ELSE 0 END)  AS one_time_customers,
    ROUND(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_pct
FROM order_counts;


-- RESTAURANT PERFORMANCE
  
-- 3.1 Highest-revenue restaurants
SELECT
    r.restaurant_id, r.restaurant_name, r.city, r.cuisine,
    ROUND(SUM(o.order_amount - o.discount_amount), 2) AS revenue,
    COUNT(*) AS orders
FROM fact_orders o
JOIN dim_restaurant r ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine
ORDER BY revenue DESC
LIMIT 20;

-- 3.2 Restaurants with the most orders (volume, all statuses)
SELECT
    r.restaurant_id, r.restaurant_name,
    COUNT(*) AS total_orders
FROM fact_orders o
JOIN dim_restaurant r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY total_orders DESC
LIMIT 20;

-- 3.3 Most popular cuisines (by orders and revenue)
SELECT
    r.cuisine,
    COUNT(*) AS orders,
    ROUND(SUM(o.order_amount - o.discount_amount), 2) AS revenue
FROM fact_orders o
JOIN dim_restaurant r ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.cuisine
ORDER BY revenue DESC;

-- 3.4 Do highly-rated restaurants generate more revenue? (rating bucket vs revenue)
SELECT
    CASE
        WHEN r.avg_rating >= 4.5 THEN '4.5 - 5.0'
        WHEN r.avg_rating >= 4.0 THEN '4.0 - 4.49'
        WHEN r.avg_rating >= 3.5 THEN '3.5 - 3.99'
        ELSE 'Below 3.5'
    END AS rating_band,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
    ROUND(SUM(o.order_amount - o.discount_amount), 2) AS revenue,
    ROUND(SUM(o.order_amount - o.discount_amount) / COUNT(DISTINCT r.restaurant_id), 2) AS revenue_per_restaurant
FROM dim_restaurant r
LEFT JOIN fact_orders o ON o.restaurant_id = r.restaurant_id AND o.order_status = 'Delivered'
GROUP BY rating_band
ORDER BY rating_band DESC;

-- 3.5 Bottom / last 5 restaurants by revenue (underperformers)
SELECT
    r.restaurant_id, r.restaurant_name, r.city, r.cuisine, r.avg_rating,
    COALESCE(ROUND(SUM(o.order_amount - o.discount_amount), 2), 0) AS revenue,
    COUNT(o.order_id) AS orders
FROM dim_restaurant r
LEFT JOIN fact_orders o ON o.restaurant_id = r.restaurant_id AND o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine, r.avg_rating
ORDER BY revenue ASC
LIMIT 5;


-- COUPON / DISCOUNT ANALYSIS
 
-- 4.1 % of orders that used a discount/coupon
SELECT
    ROUND(100.0 * SUM(CASE WHEN discount_amount > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_orders_with_discount
FROM fact_orders;

-- 4.2 Do discount/coupon users spend more than non-users? (AOV comparison)
SELECT
    CASE WHEN discount_amount > 0 THEN 'Used Discount' ELSE 'No Discount' END AS segment,
    COUNT(*) AS orders,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM fact_orders
WHERE order_status = 'Delivered'
GROUP BY segment;

-- 4.3 City with highest discount/coupon usage
SELECT
    c.city,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.discount_amount > 0 THEN 1 ELSE 0 END) AS discounted_orders,
    ROUND(100.0 * SUM(CASE WHEN o.discount_amount > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_discounted
FROM fact_orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY pct_discounted DESC;

-- 4.4 Do discount/coupon users come back more often (retention proxy)?
WITH cust_flags AS (
    SELECT
        customer_id,
        COUNT(*) AS orders,
        SUM(CASE WHEN discount_amount > 0 THEN 1 ELSE 0 END) AS discounted_orders
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE WHEN discounted_orders > 0 THEN 'Discount User' ELSE 'Never Used Discount' END AS segment,
    COUNT(*) AS customers,
    ROUND(AVG(orders), 2) AS avg_orders_per_customer,
    ROUND(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM cust_flags
GROUP BY segment;


-- CANCELLATION & REFUND ANALYSIS
 
-- 5.1 Overall cancellation rate
SELECT
    ROUND(100.0 * SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate_pct
FROM fact_orders;

-- 5.2 Overall refund rate
SELECT
    ROUND(100.0 * SUM(CASE WHEN order_status = 'Refunded' THEN 1 ELSE 0 END) / COUNT(*), 2) AS refund_rate_pct
FROM fact_orders;

-- 5.3 Revenue lost to cancellations + refunds (gross order value not realized)
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(SUM(order_amount - discount_amount), 2) AS lost_revenue
FROM fact_orders
WHERE order_status IN ('Cancelled', 'Refunded')
GROUP BY order_status;

-- 5.4 Restaurants with the highest cancellation rate (min 20 orders to avoid noise)
SELECT
    r.restaurant_id, r.restaurant_name, r.city,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(100.0 * SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate_pct
FROM fact_orders o
JOIN dim_restaurant r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city
HAVING COUNT(*) >= 20
ORDER BY cancellation_rate_pct DESC
LIMIT 20;


-- CUSTOMER CHURN ANALYSIS

-- 6.1 / 6.2 Churned customers & churn rate
WITH last_order AS (
    SELECT customer_id, MAX(order_timestamp) AS last_order_date
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
snapshot AS (
    SELECT MAX(order_timestamp) AS max_date FROM fact_orders
),
flagged AS (
    SELECT
        lo.customer_id,
        lo.last_order_date,
        CASE WHEN lo.last_order_date < (SELECT max_date FROM snapshot) - INTERVAL 90 DAY
             THEN 1 ELSE 0 END AS is_churned    -- Postgres: max_date - INTERVAL '90 days'
    FROM last_order lo
)
SELECT
    SUM(is_churned) AS churned_customers,
    COUNT(*) AS customers_with_orders,
    ROUND(100.0 * SUM(is_churned) / COUNT(*), 2) AS churn_rate_pct
FROM flagged;

-- 6.3 City with the highest churn
WITH last_order AS (
    SELECT customer_id, MAX(order_timestamp) AS last_order_date
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
snapshot AS (SELECT MAX(order_timestamp) AS max_date FROM fact_orders),
flagged AS (
    SELECT
        lo.customer_id,
        CASE WHEN lo.last_order_date < (SELECT max_date FROM snapshot) - INTERVAL 90 DAY
             THEN 1 ELSE 0 END AS is_churned
    FROM last_order lo
)
SELECT
    c.city,
    COUNT(*) AS customers,
    SUM(f.is_churned) AS churned,
    ROUND(100.0 * SUM(f.is_churned) / COUNT(*), 2) AS churn_rate_pct
FROM flagged f
JOIN dim_customer c ON c.customer_id = f.customer_id
GROUP BY c.city
ORDER BY churn_rate_pct DESC;

-- 6.4 Revenue lost due to churn (historical revenue held by churned customers)
WITH last_order AS (
    SELECT customer_id, MAX(order_timestamp) AS last_order_date
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
snapshot AS (SELECT MAX(order_timestamp) AS max_date FROM fact_orders),
flagged AS (
    SELECT
        lo.customer_id,
        CASE WHEN lo.last_order_date < (SELECT max_date FROM snapshot) - INTERVAL 90 DAY
             THEN 1 ELSE 0 END AS is_churned
    FROM last_order lo
),
cust_rev AS (
    SELECT customer_id, SUM(order_amount - discount_amount) AS rev
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    ROUND(SUM(CASE WHEN f.is_churned = 1 THEN cr.rev ELSE 0 END), 2) AS revenue_from_churned_customers,
    ROUND(SUM(cr.rev), 2) AS total_revenue,
    ROUND(100.0 * SUM(CASE WHEN f.is_churned = 1 THEN cr.rev ELSE 0 END) / SUM(cr.rev), 2) AS pct_revenue_at_risk
FROM flagged f
JOIN cust_rev cr ON cr.customer_id = f.customer_id;

-- 6.5 High-value churned customers (top 20)
WITH last_order AS (
    SELECT customer_id, MAX(order_timestamp) AS last_order_date
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
snapshot AS (SELECT MAX(order_timestamp) AS max_date FROM fact_orders),
flagged AS (
    SELECT
        lo.customer_id, lo.last_order_date,
        CASE WHEN lo.last_order_date < (SELECT max_date FROM snapshot) - INTERVAL 90 DAY
             THEN 1 ELSE 0 END AS is_churned
    FROM last_order lo
),
cust_rev AS (
    SELECT customer_id, SUM(order_amount - discount_amount) AS rev, COUNT(*) AS orders
    FROM fact_orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    c.customer_id, c.customer_name, c.city,
    f.last_order_date, cr.orders, ROUND(cr.rev, 2) AS lifetime_revenue
FROM flagged f
JOIN cust_rev cr ON cr.customer_id = f.customer_id
JOIN dim_customer c ON c.customer_id = f.customer_id
WHERE f.is_churned = 1
ORDER BY cr.rev DESC
LIMIT 20;