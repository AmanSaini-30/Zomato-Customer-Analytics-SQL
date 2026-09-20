 CREATE DATABASE ZomatoAnalytics;

USE ZomatoAnalytics;

CREATE TABLE Customers (
    customer_id VARCHAR(20) primary key,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    signup_time DATE,
    acquisition_channel VARCHAR(100)
);


select * from customers;

 CREATE TABLE Restaurants (
    restaurant_id VARCHAR(20) primary key,
    restaurant_name VARCHAR(100),
    cuisine VARCHAR(100),
    city VARCHAR(100),
    avg_rating DECIMAL(3,1)
);

 
select * from restaurants;
 
 CREATE TABLE Orders (
    order_id VARCHAR(20) primary key,
    customer_id VARCHAR(20),
    restaurant_id VARCHAR(20),
    order_timestamp DATE,
    order_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    payment_mode VARCHAR(50),
    order_status VARCHAR(50),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES Restaurants(restaurant_id)
);
 
 
 select * from orders;
 
 show create table customers;
 
-- show GLOBAL VARIABLES LIKE 'local_infile';
-- SET GLOBAL local_infile = 1;
-- SHOW GLOBAL VARIABLES LIKE 'local_infile';

 
-- Data Quality Checks

-- Check duplicates

SELECT order_id, COUNT(*) AS cnt
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Customer:

SELECT customer_id, COUNT(*) AS cnt
FROM Customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Restaurant:

SELECT restaurant_id, COUNT(*) AS cnt
FROM Restaurants
GROUP BY restaurant_id
HAVING COUNT(*) > 1;

-- Check NULLs

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN restaurant_id IS NULL THEN 1 ELSE 0 END) AS null_restaurant_id,
    SUM(CASE WHEN order_amount IS NULL THEN 1 ELSE 0 END) AS null_order_amount
FROM Orders;

-- Check invalid amounts

SELECT *
FROM Orders
WHERE order_amount < 0
   OR discount_amount < 0
   OR delivery_fee < 0;
   
-- Check status
   
SELECT order_status, COUNT(*) AS total_orders
FROM Orders
GROUP BY order_status;  

-- Revenue Analysis

-- Total Revenue

SELECT
SUM(order_amount) AS total_revenue
FROM orders
WHERE order_status = 'Delivered';

-- Monthly Revenue

SELECT
    DATE_FORMAT(order_timestamp, '%Y-%m') AS month,
    SUM(order_amount) AS monthly_revenue
FROM Orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
ORDER BY month;


-- highest revenue

SELECT
    r.city,
    SUM(o.order_amount) AS total_revenue
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.city
ORDER BY total_revenue DESC;
   
-- Revenue by Payment Mode   
   
SELECT
    payment_mode,
    SUM(order_amount) AS total_revenue
FROM Orders
WHERE order_status = 'Delivered'
GROUP BY payment_mode
ORDER BY total_revenue DESC;
 

-- AOV 

SELECT
    ROUND(
        SUM(order_amount) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM Orders
WHERE order_status = 'Delivered';


SELECT
    DATE_FORMAT(order_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    ROUND(
        SUM(order_amount) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM Orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
ORDER BY month;


-- Customer Analysis

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    SUM(o.order_amount) AS total_revenue
FROM Orders o
JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city
ORDER BY total_revenue DESC
LIMIT 20;

-- Revenue from top 20 customers

 SELECT
    ROUND(
        (
            SELECT SUM(total_revenue)
            FROM (
                SELECT customer_id,
                       SUM(order_amount) AS total_revenue
                FROM Orders
                WHERE order_status = 'Delivered'
                GROUP BY customer_id
                ORDER BY total_revenue DESC
                LIMIT 20
            ) AS top20
        )
        /
        (
            SELECT SUM(order_amount)
            FROM Orders
            WHERE order_status = 'Delivered'
        ) * 100,
        2
    ) AS top_20_revenue_percentage;

-- Acquisition channel

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(o.order_amount) AS total_revenue,
    ROUND(
        SUM(o.order_amount) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer asc;

-- Repeat customers

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id
    FROM Orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS repeat_customer_list;

-- Restaurant Analysis

-- Top restaurants by revenue

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    SUM(o.order_amount) AS total_revenue
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine
ORDER BY total_revenue DESC
LIMIT 10;

-- Top restaurants by orders

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine
ORDER BY total_orders DESC
LIMIT 10;

-- Popular cuisines

SELECT
    r.cuisine,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.cuisine
ORDER BY total_orders DESC
LIMIT 10;

-- Rating vs revenue

SELECT
    CASE
        WHEN r.avg_rating >= 4.5 THEN '4.5 - 5.0'
        WHEN r.avg_rating >= 4.0 THEN '4.0 - 4.4'
        WHEN r.avg_rating >= 3.5 THEN '3.5 - 3.9'
        ELSE 'Below 3.5'
    END AS rating_range,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
    SUM(o.order_amount) AS total_revenue,
    ROUND(
        SUM(o.order_amount) / COUNT(DISTINCT r.restaurant_id),
        2
    ) AS avg_revenue_per_restaurant
FROM Restaurants r
JOIN Orders o
    ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY rating_range
ORDER BY avg_revenue_per_restaurant DESC;

-- Last 5 Restaurant

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    SUM(o.order_amount) AS total_revenue
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city
ORDER BY total_revenue ASC
LIMIT 5;

-- Coupon Analysis

-- Coupon percentage

SELECT
    ROUND(
        SUM(CASE
            WHEN discount_amount > 0 THEN 1
            ELSE 0
        END) / COUNT(DISTINCT order_id) * 100,
        2
    ) AS coupon_usage_percentage
FROM Orders
WHERE order_status = 'Delivered';

-- Coupon vs non-coupon spending

SELECT
    CASE
        WHEN discount_amount > 0 THEN 'Coupon Users'
        ELSE 'Non-Coupon Users'
    END AS customer_type,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    ROUND(
        SUM(order_amount) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM Orders
WHERE order_status = 'Delivered'
GROUP BY
    CASE
        WHEN discount_amount > 0 THEN 'Coupon Users'
        ELSE 'Non-Coupon Users'
    END
ORDER BY AOV DESC;

 -- city uses the most coupons

SELECT
    r.city,
    COUNT(DISTINCT o.order_id) AS coupon_orders
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
  AND o.discount_amount > 0
GROUP BY r.city
ORDER BY coupon_orders DESC
LIMIT 1;

-- customer retention

SELECT
    customer_type,
    COUNT(*) AS customers,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM (
    SELECT
        o.customer_id,
        CASE
            WHEN SUM(o.discount_amount) > 0
                THEN 'Coupon Users'
            ELSE 'Non-Coupon Users'
        END AS customer_type,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM Orders o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
) AS customer_summary
GROUP BY customer_type;

-- Cancellation & Refund Analysis

-- Cancellation rate

SELECT
    ROUND(
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(DISTINCT order_id) * 100,
        2
    ) AS cancellation_rate_percentage
FROM Orders;


-- Refund rate

SELECT
    ROUND(
        SUM(CASE WHEN order_status = 'Refunded' THEN 1 ELSE 0 END)
        / COUNT(DISTINCT order_id) * 100,
        2
    ) AS refund_rate_percentage
FROM Orders;

-- Revenue associated with cancellations

SELECT
    ROUND(SUM(order_amount), 2) AS lost_revenue_due_to_cancellations
FROM Orders
WHERE order_status = 'Cancelled';

-- Restaurants with highest cancellation rate

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE
        WHEN o.order_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Cancelled' THEN 1
            ELSE 0
        END)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS cancellation_rate
FROM Orders o
JOIN Restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city
ORDER BY cancellation_rate DESC
LIMIT 5;

-- Churn Analysis

-- Churned Customers

SELECT
    COUNT(DISTINCT customer_id) AS churned_customers
FROM Orders
WHERE order_status = 'Delivered'
  AND order_timestamp < (
      SELECT DATE_SUB(MAX(order_timestamp), INTERVAL 90 DAY)
      FROM Orders
  );

-- Churn Rate

SELECT
    ROUND(
        (
            SELECT COUNT(DISTINCT customer_id)
            FROM Orders
            WHERE order_status = 'Delivered'
              AND order_timestamp < (
                  SELECT DATE_SUB(MAX(order_timestamp), INTERVAL 90 DAY)
                  FROM Orders
              )
        )
        /
        (
            SELECT COUNT(DISTINCT customer_id)
            FROM Customers
        ) * 100,
        2
    ) AS churn_rate_percentage;

-- highest churn city

SELECT
    c.city,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN o.customer_id IS NULL THEN c.customer_id
    END) AS churned_customers
FROM Customers c
LEFT JOIN (
    SELECT DISTINCT customer_id
    FROM Orders
    WHERE order_status = 'Delivered'
      AND order_timestamp >= (
          SELECT DATE_SUB(MAX(order_timestamp), INTERVAL 90 DAY)
          FROM Orders
      )
) o
    ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY churned_customers DESC
LIMIT 1;

-- revenue is lost due to churn?

SELECT
    ROUND(SUM(o.order_amount), 2) AS revenue_lost_due_to_churn
FROM Orders o
WHERE o.order_status = 'Delivered'
  AND o.customer_id IN (
      SELECT customer_id
      FROM Orders
      WHERE order_status = 'Delivered'
      GROUP BY customer_id
      HAVING MAX(order_timestamp) < (
          SELECT DATE_SUB(MAX(order_timestamp), INTERVAL 90 DAY)
          FROM Orders
      )
  );

-- high-value churned customers?

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_revenue,
    MAX(o.order_timestamp) AS last_order_date
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city
HAVING MAX(o.order_timestamp) < (
    SELECT DATE_SUB(
        MAX(order_timestamp),
        INTERVAL 90 DAY
    )
    FROM Orders
)
ORDER BY total_revenue DESC
LIMIT 20;






