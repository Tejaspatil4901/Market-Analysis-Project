USE project_orders;

SHOW TABLES;

SELECT * FROM aisles;

SELECT * FROM departments;

SELECT * FROM order_products_train ;

SELECT * FROM orders;

SELECT * FROM products;

SELECT 
    o.order_id,
    o.user_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,
    op.product_id,
    p.product_name,
    a.aisle,
    d.department,
    op.add_to_cart_order,
    op.reordered
FROM order_products_train op
JOIN orders o ON op.order_id = o.order_id
JOIN products p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id;


SET SESSION net_read_timeout=120;
SET SESSION net_write_timeout=120;
SET SESSION wait_timeout=300;


-- 1. What are the top 10 aisles with the highest number of products?
 SELECT a.aisle, COUNT(p.product_id) AS product_count
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY product_count DESC
LIMIT 10;


-- 2. How many unique departments are there in the dataset?
SELECT COUNT(DISTINCT department_id) AS unique_departments
FROM departments;


-- 3. What is the distribution of products across departments?
SELECT d.department, COUNT(p.product_id) AS total_products
FROM products p
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY total_products DESC;


-- 4. What are the top 10 products with the highest reorder rates?
SELECT p.product_name, reorder_stats.reorder_rate
FROM (
    SELECT product_id, AVG(reordered) AS reorder_rate
    FROM order_products_train
    GROUP BY product_id
) AS reorder_stats
JOIN products p ON p.product_id = reorder_stats.product_id
ORDER BY reorder_stats.reorder_rate DESC
LIMIT 10;


-- 5. How many unique users have placed orders in the dataset?
SELECT COUNT(DISTINCT user_id) AS unique_users
FROM orders;

-- 6. What is the average number of days between orders for each user?
SELECT user_id, AVG(days_since_prior_order) AS avg_days_between_orders
FROM orders
WHERE days_since_prior_order IS NOT NULL
GROUP BY user_id;

-- 7. What are the peak hours of order placement during the day?
SELECT order_hour_of_day, COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;

-- 8. How does order volume vary by day of the week?
SELECT order_dow, COUNT(*) AS total_orders
FROM orders
GROUP BY order_dow
ORDER BY order_dow;


-- 9. What are the top 10 most ordered products?
SELECT p.product_name, order_counts.total_orders
FROM (
    SELECT product_id, COUNT(*) AS total_orders
    FROM order_products_train
    GROUP BY product_id
) AS order_counts
JOIN products p ON order_counts.product_id = p.product_id
ORDER BY order_counts.total_orders DESC
LIMIT 10;

-- 10. How many users have placed orders in each department?
SELECT d.department, COUNT(DISTINCT o.user_id) AS users
FROM order_products_train op
JOIN orders o ON op.order_id = o.order_id
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department;

-- 11. What is the average number of products per order?
SELECT AVG(product_count) AS avg_products_per_order
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) AS sub;


-- 12. What are the most reordered products in each department?
SELECT 
    d.department, 
    p.product_name, 
    pr.total_reorders
FROM (
    SELECT product_id, SUM(reordered) AS total_reorders
    FROM order_products_train
    GROUP BY product_id
) AS pr
JOIN products p ON pr.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
ORDER BY d.department, pr.total_reorders DESC;


-- 13. How many products have been reordered more than once?
SELECT COUNT(*) AS products_reordered_more_than_once
FROM (
    SELECT product_id
    FROM order_products_train
    GROUP BY product_id
    HAVING SUM(reordered) > 1
) AS reordered_products;


-- 14. What is the average number of products added to the cart per order?
SELECT AVG(cart_size) AS avg_cart_size
FROM (
    SELECT order_id, COUNT(product_id) AS cart_size
    FROM order_products_train
    GROUP BY order_id
) AS sub;


-- 15. How does the number of orders vary by hour of the day?
SELECT order_hour_of_day, COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;


-- 16. What is the distribution of order sizes (number of products per order)?
SELECT product_count, COUNT(*) AS number_of_orders
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) AS sub
GROUP BY product_count
ORDER BY product_count;


-- Step 1: Pre-aggregate reorder rates per product
SELECT 
    a.aisle, 
    AVG(pr.reorder_rate) AS avg_reorder_rate
FROM (
    SELECT product_id, AVG(reordered) AS reorder_rate
    FROM order_products_train
    GROUP BY product_id
) AS pr
JOIN products p ON pr.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY avg_reorder_rate DESC;


-- 18. How does the average order size vary by day of the week?
SELECT o.order_dow, AVG(product_count) AS avg_order_size
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) AS op
JOIN orders o ON op.order_id = o.order_id
GROUP BY o.order_dow;


-- 19. What are the top 10 users with the highest number of orders?
SELECT user_id, COUNT(*) AS total_orders
FROM orders
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;

-- 20. How many products belong to each aisle and department?
SELECT a.aisle, d.department, COUNT(p.product_id) AS total_products
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY a.aisle, d.department
ORDER BY total_products DESC;





