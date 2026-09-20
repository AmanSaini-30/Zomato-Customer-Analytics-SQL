# 🍽️ Zomato SQL Data Analysis Project

## 📌 Project Overview

This project analyzes **Zomato-style food delivery data using MySQL** to generate meaningful business insights related to customers, restaurants, orders, revenue, coupons, cancellations, refunds, and customer churn.

The main objective of this project is to use SQL for **data cleaning, data quality validation, business analysis, and KPI generation** to understand business performance and support data-driven decision-making.

---

## 🎯 Project Objectives

The key objectives of this project are:

* Analyze overall revenue and order performance
* Identify top-performing restaurants and cities
* Analyze customer purchasing behavior
* Understand customer acquisition channels
* Identify repeat customers
* Analyze popular cuisines
* Compare restaurant ratings with revenue
* Analyze coupon usage and its impact on AOV
* Calculate cancellation and refund rates
* Identify revenue lost due to cancellations
* Analyze customer churn
* Identify high-value churned customers
* Perform data quality checks using SQL

---

## 🗂️ Database Schema

The project contains three main tables:

### 1. Customers

Contains customer information.

| Column                | Description                 |
| --------------------- | --------------------------- |
| `customer_id`         | Unique customer ID          |
| `customer_name`       | Customer name               |
| `city`                | Customer city               |
| `signup_time`         | Customer signup date        |
| `acquisition_channel` | Customer acquisition source |

### 2. Restaurants

Contains restaurant information.

| Column            | Description               |
| ----------------- | ------------------------- |
| `restaurant_id`   | Unique restaurant ID      |
| `restaurant_name` | Restaurant name           |
| `cuisine`         | Type of cuisine           |
| `city`            | Restaurant city           |
| `avg_rating`      | Average restaurant rating |

### 3. Orders

Contains order transaction information.

| Column            | Description          |
| ----------------- | -------------------- |
| `order_id`        | Unique order ID      |
| `customer_id`     | Customer reference   |
| `restaurant_id`   | Restaurant reference |
| `order_timestamp` | Order date           |
| `order_amount`    | Order value          |
| `discount_amount` | Discount amount      |
| `delivery_fee`    | Delivery fee         |
| `payment_mode`    | Payment method       |
| `order_status`    | Order status         |

---

## 🔗 Table Relationships

```text
Customers
   │
   │ customer_id
   ▼
Orders
   │
   │ restaurant_id
   ▼
Restaurants
```

* `Customers.customer_id` → `Orders.customer_id`
* `Restaurants.restaurant_id` → `Orders.restaurant_id`

Foreign keys are used to maintain relationships between the tables.

---

## 🧹 Data Quality Checks

Before performing analysis, several data quality checks were performed:

* Duplicate order IDs
* Duplicate customer IDs
* Duplicate restaurant IDs
* NULL values
* Invalid negative amounts
* Order status validation

Example:

```sql
SELECT order_id, COUNT(*) AS cnt
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

This helps identify duplicate orders.

---

# 📊 Business Analysis

## 💰 1. Revenue Analysis

The project analyzes:

* Total revenue
* Monthly revenue
* Revenue by city
* Revenue by payment mode
* Average Order Value (AOV)
* Monthly orders and AOV

Example KPI:

```text
Total Revenue
Monthly Revenue
Average Order Value
Revenue by City
Revenue by Payment Mode
```

---

## 👥 2. Customer Analysis

Customer-level analysis includes:

* Top 20 customers by revenue
* Revenue contribution from top customers
* Customer acquisition channels
* Revenue per customer
* Repeat customers

Example:

```sql
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
```

---

## 🏪 3. Restaurant Analysis

The project identifies:

* Top restaurants by revenue
* Top restaurants by number of orders
* Popular cuisines
* Restaurant performance by city
* Revenue performance by rating range
* Restaurants with lower revenue

---

## 🎟️ 4. Coupon Analysis

Coupon-related analysis includes:

* Coupon usage percentage
* Coupon users vs non-coupon users
* AOV comparison
* Revenue comparison
* City with the highest coupon usage
* Customer retention comparison

Example:

```text
Coupon Users
        vs
Non-Coupon Users
```

This analysis helps understand customer behavior associated with discounts.

---

## ❌ 5. Cancellation & Refund Analysis

The project calculates:

* Cancellation rate
* Refund rate
* Revenue associated with cancellations
* Restaurants with high cancellation rates

Example KPI:

```text
Cancellation Rate %
Refund Rate %
Lost Revenue from Cancellations
```

---

## 🔄 6. Customer Churn Analysis

Customer churn analysis includes:

* Number of churned customers
* Churn rate
* City with the highest churn
* Revenue lost due to churn
* High-value churned customers

A customer is considered churned based on the project's **90-day inactivity definition**.

---

# 🛠️ SQL Skills Demonstrated

This project demonstrates practical SQL skills including:

* `CREATE DATABASE`
* `CREATE TABLE`
* Primary Keys
* Foreign Keys
* `SELECT`
* `WHERE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* `LIMIT`
* `JOIN`
* `LEFT JOIN`
* Subqueries
* Derived tables
* `CASE WHEN`
* Aggregate functions

  * `SUM()`
  * `COUNT()`
  * `AVG()`
  * `ROUND()`
* Date functions

  * `DATE_FORMAT()`
  * `DATE_SUB()`
* Data quality checks
* KPI calculations
* Business analysis

---

# 📈 Key Business KPIs

The project calculates several important KPIs:

| KPI               | Purpose                      |
| ----------------- | ---------------------------- |
| Total Revenue     | Measures overall sales       |
| Monthly Revenue   | Tracks revenue trends        |
| Total Orders      | Measures order volume        |
| AOV               | Measures average order value |
| Repeat Customers  | Measures customer engagement |
| Coupon Usage %    | Measures discount adoption   |
| Cancellation Rate | Measures order cancellations |
| Refund Rate       | Measures refunded orders     |
| Churn Rate        | Measures customer inactivity |
| Revenue Lost      | Estimates revenue impact     |

---

 
# 📁 Project Files

```text
Zomato-SQL-Analytics/
│
├── SQL Project Zomato.sql
└── README.md
```

# 🎓 What I Learned

Through this project, I developed practical experience in:

* Writing SQL queries for business problems
* Working with relational databases
* Joining multiple tables
* Performing data quality checks
* Creating business KPIs
* Analyzing customer behavior
* Revenue and restaurant performance analysis
* Customer churn analysis
* Translating business questions into SQL queries

---

 
## ⭐ Project Highlights

**Domain:** Food Delivery / E-commerce Analytics
**Database:** MySQL
**Project Type:** SQL Data Analysis
**Focus Areas:** Revenue, Customers, Restaurants, Coupons, Cancellations, Refunds & Churn

---

## 📌 Author

**Aman Saini**

*Aspiring Data Analyst*
 
