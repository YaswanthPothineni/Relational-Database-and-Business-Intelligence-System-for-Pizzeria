-- Query1
-- Description: Fetches all relevant details for each order, including the order ID, date, item name, price, quantity, customer name, and delivery address by joining the 'orders', 'items', 'customers', and 'addresses' tables.

SELECT 
  o.order_id, 
  o.created_at, 
  i.name AS item_name, 
  i.price AS item_price, 
  o.quantity, 
  c.first_name || ' ' || c.last_name AS customer_name, 
  a.street || ', ' || a.city || ', ' || a.zip_code AS delivery_address
FROM 
  orders o
  JOIN items i ON o.item_id = i.item_id
  JOIN customers c ON o.customer_id = c.customer_id
  JOIN addresses a ON o.address_id = a.address_id;


-- Query2
-- Description: Calculates the total number of orders and total sales revenue for each item category by grouping the data from the 'orders' and 'items' tables by the category.

SELECT 
  i.category, 
  COUNT(o.order_id) AS total_orders, 
  SUM(i.price * o.quantity) AS total_sales
FROM 
  orders o
  JOIN items i ON o.item_id = i.item_id
GROUP BY 
  i.category;


-- Query3
-- Description: Assesses inventory usage for each ingredient, calculating the total used, current stock, remaining stock, and indicates whether a reorder is needed based on the threshold of 25% of the current stock.

SELECT 
  ing.ingredient_id, 
  ing.name AS ingredient_name, 
  SUM(r.quantity) AS total_used, 
  inv.quantity AS current_stock, 
  (inv.quantity - SUM(r.quantity)) AS remaining_stock,
  CASE 
    WHEN (inv.quantity - SUM(r.quantity)) < (0.25 * inv.quantity) THEN 'Reorder Needed'
    ELSE 'Sufficient Stock'
  END AS reorder_status
FROM 
  recipes r
  JOIN ingredients ing ON r.ingredient_id = ing.ingredient_id
  JOIN inventory inv ON ing.ingredient_id = inv.ingredient_id
GROUP BY 
  ing.ingredient_id, 
  ing.name, 
  inv.quantity;


