use  pizzahut
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id))
-----------------------------------------
create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id))
-----------------------------------------

-- Retrieve the total number of orders placed. 

select count(*) as total_orders from orders
------------------------------------------

-- Calculate the total revenue generated from pizza sales. 

SELECT 
    ROUND(SUM(pizzas.price * orders_details.quantity),
            2) AS total_revenue_generated
FROM
    pizzas
        JOIN
    orders_details USING (pizza_id)
    -----------------------------------------------
    
    -- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
order by pizzas.price desc limit 1
-----------------------------------------------

-- identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(orders_details.order_details_id) as c
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
    group by pizzas.size order by c desc limit 1
    --------------------------------------------------
    
    -- Join the necessary tables to find the total quantity of each pizza category ordered.                                     

SELECT 
    pizza_types.category, sum(orders_details.quantity) AS c
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id 
    join pizza_types on 
    pizza_types.pizza_type_id=pizzas.pizza_type_id
    group by category order by c desc
    -----------------------------------------------------
    
    -- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, COUNT(orders_details.quantity) AS c
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY c DESC
LIMIT 5 
----------------------------------------------------------

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as t , count(order_id) from orders group by t
--------------------------------------------------------

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) from pizza_types group by category 
----------------------------------------------------------

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    round(avg(quantity),0)
FROM
    (SELECT 
        order_date, SUM(quantity) as quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY order_date) as order_quantity
    -------------------------------------------------------

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name, SUM(quantity * price) as s
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
    
    group by pizza_types.name order by s desc limit 3
    -------------------------------------------------------
    
-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date)
 from 
(select orders.order_date,sum(orders_details.quantity*pizzas.price) as revenue 
from orders_details
 join pizzas on orders_details.pizza_id =pizzas.pizza_id 
 join orders on orders.order_id=orders_details.order_id
 group by orders.order_date) as sales 
 ------------------------------------------------------------
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from (select category,name, revenue,rank() over(partition by category order by revenue desc) as rn from 
(select pizza_types.category,pizza_types.name, sum((orders_details.quantity)*pizzas.price) as revenue 
from pizza_types
 join pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id 
 join orders_details on orders_details.pizza_id=pizzas.pizza_id
 group by pizza_types.category,pizza_types.name) as a)as b 
 where rn<=3