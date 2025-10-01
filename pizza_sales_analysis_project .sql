-- 1. Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders ;

-- 2. Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity * p.price),2)as total_revenus from pizzas p
inner join order_details od 
on p.pizza_id = od.pizza_id;

-- 3.Identify the highest-priced pizza.
SELECT pt.name, p.price AS highest_priced
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
limit 1 ;

-- 4.Identify the most common pizza size ordered.
select p.size , count(od.order_details_id) as common_size
from pizzas p
join order_details od 
on od.pizza_id = p.pizza_id 
group by p.size 
order by common_size desc ;


-- 5. List the top 5 most ordered pizza types along with their quantities.
select pt.name , sum(od.quantity) as top_quantity
from pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od 
on p.pizza_id  = od.pizza_id 
group by pt.name 
order by top_quantity desc 
limit 5; 

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category , sum(od.quantity) total_quantity 
from pizza_types pt
join pizzas p 
on p.pizza_type_id = pt.pizza_type_id 
join order_details od 
on od.pizza_id = p.pizza_id 
group by category 
order by total_quantity desc ;

-- 7. Determine the distribution of orders by hour of the day.
select hour(o.order_time)as hour , count(o.order_id) as order_id
from orders o 
group by hour(o.order_time)
order by  hour(o.order_time),order_id ;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.
select category ,count(name ) 
from pizza_types
group by category ;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(avg_num),0) from (select o.order_date , sum(od.quantity ) as avg_num
from orders o 
join order_details od
on od.order_id = o.order_id 
group by o.order_date) as order_quantity ;

-- 10.Determine the top 3 most ordered pizza types based on revenue.
select pt.name , sum(od.quantity * p.price) as top_most
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id 
group by pt.name 
order by top_most desc 
limit 3 ;

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

WITH total_revenue AS (
    SELECT SUM(od.quantity * p.price) AS total_rev
    FROM pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
)
SELECT 
    pt.name AS pizza_type,
    ROUND(SUM(od.quantity * p.price) / tr.total_rev * 100, 2) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
CROSS JOIN total_revenue tr
GROUP BY pt.name, tr.total_rev
ORDER BY revenue_percentage DESC;

-- 12. Analyze the cumulative revenue generated over time.

SELECT
    o.order_date,
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) 
        OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
WITH revenue_per_pizza AS (
    SELECT
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity * p.price) AS revenue
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
)
SELECT category, pizza_name, revenue
FROM (
    SELECT 
        category,
        pizza_name,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM revenue_per_pizza
) ranked
WHERE rn <= 3
ORDER BY category, revenue DESC;










