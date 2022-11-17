CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  `customer_id` VARCHAR(1),
  `order_date` DATE,
  `product_id` INTEGER
);

INSERT INTO sales
  (`customer_id`, `order_date`, `product_id`)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  `product_id` INTEGER,
  `product_name` VARCHAR(5),
  `price` INTEGER
);

INSERT INTO menu
  (`product_id`, `product_name`, `price`)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  `customer_id` VARCHAR(1),
  `join_date` DATE
);

INSERT INTO members
  (`customer_id`, `join_date`)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM sales s;
SELECT * FROM members m;
SELECT * FROM menu s;

-- 1)What is the total amount each customer spent at the restaurant?

select customer_id,sum(price) as total_spent
from menu m join sales s on m.product_id=s.product_id
group by customer_id;

-- 2)How many days has each customer visited the restaurant?

select customer_id,count(distinct(order_date)) as days_visted
from sales group by customer_id;

-- 3)What was the first item from the menu purchased by each customer?

with CTE as(
select s.customer_id,m.product_name, row_number() over(partition by s.customer_id order by s.order_date) rnk
  from sales s
join menu m  on s.product_id=m.product_id)
select customer_id,product_name from CTE where rnk='1';

-- 4)What is the most purchased item on the menu and how many times was it purchased by all customers?

with cte as
(select m.product_name,count(s.product_id) as no_of_purchase,
row_number() over(order by count(s.product_id) desc ) as rnk
from sales s join menu m on s.product_id=m.product_id group by s.product_id )
select product_name,no_of_purchase from cte where rnk='1';


-- 5)Which item was the most popular for each customer?

with cte as(
select customer_id,s.product_id,m.product_name,count(s.product_id) as popularity_dish_count,
rank()over(partition by customer_id order by count(s.product_id) desc) rnk
 from sales s join menu m on s.product_id =m.product_id
group by customer_id,s.product_id)
select customer_id,product_name,popularity_dish_count from cte where rnk='1';

-- 6)Which item was purchased first by the customer after they became a member?with CTE as (

with CTE as (
select s.customer_id,s.order_date,
s.product_id,m.product_name,m1.join_date,
row_number() over(partition by s.customer_id order by order_date) rnk
from sales s left join menu m on  s.product_id = m.product_id inner join members m1
on s.customer_id=m1.customer_id
where s.order_date>=m1.join_date)
select customer_id,order_date,product_name
   from CTE where rnk='1';

-- 7)Which item was purchased just before the customer became a member?

with CTE AS
(
select s.customer_id, m.product_name, s.order_date, m1.join_date
, row_number() over (partition by s.customer_id order by s.order_date  ) Rnk
from sales s
left join menu m
on s.product_id = m.product_id
inner join members m1
on s.customer_id = m1.customer_id
where s.order_date < m1.join_date )
select customer_id,product_name,order_date,join_date from CTE where rnk in(2,3) group by Rnk

-- 8)What is the total items and amount spent for each member before they became a member?

with CTE as(
select s.customer_id,s.product_id, m.product_name, s.order_date, m1.join_date,m.price,
row_number() over(partition by s.customer_id order by s.order_date)
from  sales s join menu m on s.product_id=m.product_id
inner join members m1
on s.customer_id = m1.customer_id
where s.order_date < m1.join_date )
select customer_id,count(product_id) ,sum(price) from CTE group by customer_id;


-- 9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


select s.customer_id,s.product_id,m.product_name,
sum(case m.product_name when 'sushi' then m.price*2 else m.price*1 end)  points
from  sales s join menu m on s.product_id=m.product_id
group by s.customer_id;
-- 10)In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi how many points do customer A and B have at the end of January?

select s.customer_id
, sum(case when s.order_date between date(m1.join_date) and date(m1.join_date +interval 6 day)
then m.price * 2 else m.price * 1 end) points
from sales s
left join menu m
on s.product_id = m.product_id
inner join members m1
on s.customer_id = m1.customer_id
where s.order_date between m1.join_date and '2021-01-31'
group by s.customer_id;











