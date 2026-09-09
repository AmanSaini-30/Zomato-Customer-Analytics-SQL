 # 🍔 Zomato Customer Analytics - SQL Portfolio Project

## 📌 Project Context
Zomato is one of India's largest food delivery platforms, connecting millions of customers with restaurants across multiple cities[cite: 1]. Over the last few months, the leadership team observed that despite a growing user base, overall business performance was not improving at the expected rate[cite: 1]. Revenue growth was inconsistent, customer retention was declining, and certain restaurant partners were underperforming[cite: 1].

**Objective:** The goal of this project is to act as a Data Analyst to investigate customer, restaurant, and order data to uncover actionable insights and provide data-driven recommendations to improve growth, customer retention, and operational efficiency[cite: 1].

---

## 🗄️ Database Structure
The project utilizes three main tables designed in a classic star schema[cite: 2]:

*   **`dim_customer`**: Contains customer details including `customer_id`, `city`, and `acquisition_channel`[cite: 2].
*   **`dim_restaurant`**: Contains restaurant details including `restaurant_id`, `cuisine`, and `avg_rating`[cite: 2].
*   **`fact_orders`**: Contains transactional data including `order_amount`, `discount_amount`, `payment_mode`, and `order_status` (Delivered / Cancelled / Refunded)[cite: 2].

---

## 📊 Key Areas of Analysis & Business Questions Answered
The SQL scripts in this repository tackle 6 core business categories[cite: 1]:

### 1. Revenue Analysis
*   Calculated total realized revenue and Average Order Value (AOV)[cite: 1, 2].
*   Evaluated month-over-month revenue trends[cite: 1, 2].
*   Identified the highest-contributing cities and most popular payment modes[cite: 1, 2].

### 2. Customer Analysis
*   Identified the Top 20 customers by revenue and performed a Pareto check to see the percentage of total revenue they contribute[cite: 1, 2].
*   Analyzed customer acquisition channels to find which brings in the highest-value users[cite: 1, 2].
*   Calculated the percentage of repeat customers versus one-time buyers[cite: 1, 2].

### 3. Restaurant Performance
*   Ranked top-performing restaurants by revenue and order volume[cite: 1, 2].
*   Analyzed the correlation between highly-rated restaurants and their revenue generation[cite: 1, 2].
*   Identified the bottom 5 underperforming restaurants to inform potential partner interventions[cite: 1, 2].

### 4. Coupon & Discount Analysis
*   Determined the percentage of orders utilizing coupons[cite: 1, 2].
*   Compared the Average Order Value (AOV) between coupon users and non-users[cite: 1, 2].
*   Assessed if coupon usage acts as a driver for customer retention (repeat orders)[cite: 1, 2].

### 5. Cancellation & Refund Analysis
*   Calculated the overall cancellation and refund rates[cite: 1, 2].
*   Quantified the exact gross revenue lost due to cancellations and refunds[cite: 1, 2].
*   Identified the top restaurants with the highest cancellation rates[cite: 1, 2].

### 6. Customer Churn Analysis
*   Defined and calculated the customer churn rate (using a 90-day inactivity threshold)[cite: 2].
*   Identified which cities experience the highest churn[cite: 1, 2].
*   Calculated the total historical revenue associated with churned customers[cite: 1, 2].
*   Pinpointed the Top 20 high-value customers who have churned for targeted re-engagement campaigns[cite: 1, 2].

---

## 🛠️ SQL Techniques Showcased
This project demonstrates proficiency in advanced SQL concepts, including:
*   **Joins:** `INNER JOIN`, `LEFT JOIN`[cite: 2].
*   **Aggregations:** `SUM()`, `AVG()`, `COUNT()`, `COUNT(DISTINCT)`[cite: 2].
*   **Common Table Expressions (CTEs):** Used extensively to break down complex queries (e.g., isolating customer order histories before joining with main tables)[cite: 2].
*   **Window Functions:** `ROW_NUMBER() OVER()` for ranking customers[cite: 2].
*   **Conditional Aggregation:** `SUM(CASE WHEN...)` for pivoting and flagging data[cite: 2].
*   **Date & Time Functions:** `DATE_FORMAT()`, `INTERVAL` calculations for churn logic[cite: 2].

