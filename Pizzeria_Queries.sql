-- Query1
-- Description: This query retrieves detailed information for each order from Ben's Pizzeria's database. It includes the order ID, item price, quantity ordered, item category, item name, date of order creation, delivery address details, and delivery status. The query performs left joins on the 'item' and 'address' tables to fetch associated data using the foreign keys in the 'orders' table.

SELECT
  o.order_id,
  i.item_price,
  o.quantity,
  i.item_cat,
  i.item_name,
  o.created_at,
  a.delivery_address1,
  a.delivery_address2,
  a.delivery_city,
  a.delivery_zipcode,
  o.delivery
FROM
  orders o
  LEFT JOIN item i ON o.item_id = i.item_id
  LEFT JOIN address a ON o.address_id = a.address_id;


-- Description: This SQL query is designed to calculate the inventory usage for a pizzeria. It computes the total weight of ingredients ordered, the cost per unit of ingredient, and the total cost of ingredients used in the orders. The subquery (s1) aggregates the quantity of each item ordered and joins with the item, recipe, and ingredient tables to get the necessary details. The outer query then calculates the additional metrics for each ingredient based on the recipe requirements and the orders made. This can help in understanding the cost distribution of ingredients per pizza item sold and in making informed decisions for inventory management and pricing strategies.

SELECT
  s1.item_name,
  s1.ing_id,
  s1.ing_name,
  s1.ing_weight,
  s1.ing_price,
  s1.order_quantity,
  s1.recipe_quantity,
  s1.order_quantity * s1.recipe_quantity AS ordered_weight,
  s1.ing_price / s1.ing_weight AS unit_cost,
  s1.order_quantity * s1.recipe_quantity * (s1.ing_price / s1.ing_weight) AS ingredient_cost
FROM
  (SELECT
    o.item_id,
    i.item_name,
    r.ing_id,
    ing.ing_name,
    ing.ing_weight,
    ing.ing_price,
    r.quantity AS recipe_quantity,
    SUM(o.quantity) AS order_quantity
  FROM
    orders o
    LEFT JOIN item i ON o.item_id = i.item_id
    LEFT JOIN recipe r ON i.sku = r.recipe_id
    LEFT JOIN ingredient ing ON r.ing_id = ing.ing_id
  GROUP BY
    o.item_id,
    i.item_name,
    r.ing_id,
    ing.ing_name,
    ing.ing_weight,
    ing.ing_price) s1;



-- Description: This SQL query is constructed to manage inventory levels by calculating the total and remaining weight of ingredients in stock at Ben's Pizzeria. The subquery s2 aggregates the total weight of each ingredient that has been ordered. The main query then calculates the total weight of ingredients in inventory (total_inv_weight) and the weight remaining after subtracting the ordered weight (remaining_weight). This helps in determining the current stock levels for each ingredient and is essential for identifying when it's necessary to reorder stock, thus ensuring that the pizzeria can maintain uninterrupted service.

SELECT
  s2.ing_name,
  s2.ordered_weight,
  ing.ing_weight * inv.quantity AS total_inv_weight,
  (ing.ing_weight * inv.quantity) - s2.ordered_weight AS remaining_weight
FROM
  (SELECT
    ing_id,
    ing_name,
    SUM(ordered_weight) AS ordered_weight
   FROM
    stock1
   GROUP BY
    ing_name, ing_id) s2
LEFT JOIN inventory inv ON inv.item_id = s2.ing_id
LEFT JOIN ingredient ing ON ing.ing_id = s2.ing_id;

-- Description:This SQL query is designed to calculate the total hours worked by each staff member per shift and the corresponding labor cost for that shift at Ben's Pizzeria. It calculates the difference between the shift end time and start time, converts this duration into hours, and then multiplies by the staff's hourly rate to determine the labor cost. The query joins the 'rota', 'staff', and 'shift' tables to collate the shift details with the staff information. This allows for a detailed analysis of staffing costs and can assist in workforce planning and budgeting.
SELECT
  r.date,
  s.first_name,
  s.last_name,
  s.hourly_rate,
  sh.start_time,
  sh.end_time,
  (HOUR(TIMEDIFF(sh.end_time, sh.start_time)) * 60 + MINUTE(TIMEDIFF(sh.end_time, sh.start_time))) / 60 AS hours_in_shift,
  ((HOUR(TIMEDIFF(sh.end_time, sh.start_time)) * 60 + MINUTE(TIMEDIFF(sh.end_time, sh.start_time))) / 60) * s.hourly_rate AS staff_cost
FROM
  rota r
  LEFT JOIN staff s ON r.staff_id = s.staff_id
  LEFT JOIN shift sh ON r.shift_id = sh.shift_id;

