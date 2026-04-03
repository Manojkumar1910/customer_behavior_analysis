-- =============================================================
-- Project  : Customer Shopping Behavior Analysis
-- Author   : Manojkumar
-- Database : customer_behavior
-- Table    : customers
-- Description:
--   This script contains 10 business insight queries on the
--   customer_shopping_behavior dataset. Topics covered include
--   revenue breakdown, customer segmentation, product performance,
--   discount behavior, subscription value, and age group analysis.
-- =============================================================
 
USE customer_behavior;
 
-- Quick preview of the dataset structure
SELECT * FROM customers LIMIT 10;
 
 
-- =============================================================
-- Q1. Revenue by Gender
-- Goal: Compare total purchase amounts across male and female customers
-- =============================================================
SELECT
    gender,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customers
GROUP BY gender;
 
 
-- =============================================================
-- Q2. High-Value Discounted Customers
-- Goal: Find customers who used a discount but still spent above the
--       overall average purchase amount (value seekers, not just bargain hunters)
-- =============================================================
SELECT
    customer_id,
    purchase_amount
FROM customers
WHERE
    discount_applied = 'Yes'
    AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customers);
 
 
-- =============================================================
-- Q3. Top 5 Highest-Rated Products
-- Goal: Identify which products customers rate most highly on average
-- =============================================================
SELECT
    item_purchased                          AS product,
    ROUND(AVG(review_rating), 2)            AS avg_rating
FROM customers
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;
 
 
-- =============================================================
-- Q4. Average Spend by Shipping Type
-- Goal: Compare average purchase amounts for Standard vs Express shipping
--       to understand if faster shipping correlates with higher spending
-- =============================================================
SELECT
    shipping_type,
    ROUND(AVG(purchase_amount), 2)          AS avg_spend
FROM customers
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;
 
 
-- =============================================================
-- Q5. Subscriber vs Non-Subscriber Spending
-- Goal: Determine whether subscribed customers are more valuable
--       by comparing average and total spend per subscription group
-- =============================================================
SELECT
    subscription_status,
    COUNT(customer_id)                      AS total_customers,
    ROUND(AVG(purchase_amount), 2)          AS avg_spend,
    ROUND(SUM(purchase_amount), 2)          AS total_revenue
FROM customers
GROUP BY subscription_status
ORDER BY total_revenue DESC;
 
 
-- =============================================================
-- Q6. Products with the Highest Discount Usage Rate
-- Goal: Find the top 5 products where discounts are applied most
--       frequently — useful for reviewing promotional dependency
-- =============================================================
SELECT
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    )                                       AS discount_rate_pct
FROM customers
GROUP BY item_purchased
ORDER BY discount_rate_pct DESC
LIMIT 5;
 
 
-- =============================================================
-- Q7. Customer Loyalty Segmentation
-- Goal: Categorize customers into New, Returning, or Loyal segments
--       based on their number of previous purchases
--       Segments: New = 1 purchase | Returning = 2–10 | Loyal = 11+
-- =============================================================
WITH customer_segments AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1              THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE                                          'Loyal'
        END AS customer_segment
    FROM customers
)
SELECT
    customer_segment,
    COUNT(*)                                AS total_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;
 
 
-- =============================================================
-- Q8. Top 3 Most Purchased Products per Category
-- Goal: Rank products within each category by order volume
--       Uses ROW_NUMBER() window function for per-category ranking
-- =============================================================
WITH ranked_items AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id)                  AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        )                                   AS item_rank
    FROM customers
    GROUP BY category, item_purchased
)
SELECT
    item_rank,
    category,
    item_purchased,
    total_orders
FROM ranked_items
WHERE item_rank <= 3
ORDER BY category, item_rank;
 
 
-- =============================================================
-- Q9. Repeat Buyers and Subscription Likelihood
-- Goal: Among customers with more than 5 previous purchases,
--       check what proportion are subscribed vs not
-- =============================================================
SELECT
    subscription_status,
    COUNT(customer_id)                      AS repeat_buyers
FROM customers
WHERE previous_purchases > 5
GROUP BY subscription_status
ORDER BY repeat_buyers DESC;
 
 
-- =============================================================
-- Q10. Revenue Contribution by Age Group
-- Goal: Identify which age group drives the most revenue
--       Assumes an age_group column exists or is derived in the table
-- =============================================================
SELECT
    age_group,
    ROUND(SUM(purchase_amount), 2)          AS total_revenue
FROM customers
GROUP BY age_group
ORDER BY total_revenue DESC;
ORDER BY total_revenue desc;
