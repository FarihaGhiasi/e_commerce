--What is the category generating the maximum sales revenue?
SELECT c.name 
FROM category c 
JOIN product p ON c.id = p.cat_id 
JOIN order_details od ON p.id = od.product_id 
GROUP BY c.id 
ORDER BY SUM(od.sales) DESC LIMIT 1;
--result = technology 

--What about the profit in this category?
SELECT c.name, SUM(od.profit) as Profit
FROM category c 
JOIN product p ON c.id = p.cat_id 
JOIN order_details od ON p.id = od.product_id 
WHERE c.name = 'Technology';

--Are they making a loss in any categroies?

SELECT distinct c.name
FROM category c 
JOIN product p ON c.id = p.cat_id 
JOIN order_details od ON p.id = od.product_id 
WHERE od.profit < 0;


--What are 5 states generating the maximum and minimum sales revenue?
select c.state, sum(od.sales) as total
from customer c
join orders o on c.id = o.customer_id
join order_details od on o.id = od.order_id
group by c.state
order by total DESC 
limit 5;

select c.state, sum(od.sales) as total
from customer c 
join orders o on c.id = o.customer_id
join order_details od on o.id = od.order_id
group by c.state
order by total 
limit 5;

--What are the 3 products in each product segment with the highest sales?
--product category 
SELECT segment, product_name, total_sales
FROM (
  SELECT c.segment, p.product_name, SUM(od.sales) as total_sales,
         ROW_NUMBER() OVER (PARTITION BY c.segment ORDER BY SUM(sales) DESC) as rank
  from product p 
  join order_details od on od.product_id = p.id
  join orders o on o.id = od.order_id
  join customer c on o.customer_id = c.id 
  group by c.segment, p.product_name
) ranked_products
WHERE rank <= 3
ORDER BY segment, rank;

--Are they the 3 most profitable products as well?
SELECT segment, product_name, total_profit
FROM (
  SELECT c.segment, p.product_name, SUM(od.profit) as total_profit,
         ROW_NUMBER() OVER (PARTITION BY c.segment ORDER BY SUM(od.sales) DESC) as rank
  from product p 
  join order_details od on od.product_id = p.id
  join orders o on o.id = od.order_id
  join customer c on o.customer_id = c.id 
  group by c.segment, p.product_name
) ranked_products
WHERE rank <= 3
ORDER BY segment, rank;


--What are the 3 best-seller products in each product segment? (Quantity-wise)
--category wise
SELECT segment, product_name, total_quantity
FROM (
  SELECT c.segment, p.product_name, SUM(od.quantity) as total_quantity,
         ROW_NUMBER() OVER (PARTITION BY c.segment ORDER BY SUM(od.quantity) DESC) as rank
  from product p 
  join order_details od on od.product_id = p.id
  join orders o on o.id = od.order_id
  join customer c on o.customer_id = c.id 
  group by c.segment, p.product_name
) ranked_products
WHERE rank <= 3
ORDER BY segment, rank;


--What are the top 3 worst-selling products in every category? (Quantity-wise)
--category wise
SELECT name, product_name, total_quantity
FROM (
  SELECT c.name, p.product_name, SUM(od.quantity) as total_quantity,
         ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY SUM(od.quantity) ASC) as rank
  FROM product p 
  JOIN order_details od on od.product_id = p.id
  JOIN orders o on o.id = od.order_id
  JOIN category c on p.cat_id = c.id 
  GROUP BY c.name, p.product_name
) ranked_products
WHERE rank <= 3
ORDER BY name, rank;


--How many unique customers per month are there for the year 2016. (There's a catch here: contrary to other 
--'heavier' RDBMS, SQLite does not support the functions YEAR() or MONTH() to extract the year or the month 
--in a date. You will have to create two new columns: year and month.)
select count(DISTINCT o.customer_id), month(od.order_date), year(od.order_date)
from orders o 
join order_details od on o.id = od.order_id 
where year(od.order_date) = '2016'
group by month(od.order_date)

