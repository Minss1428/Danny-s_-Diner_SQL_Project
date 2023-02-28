use SqlPortfolio

-- 1. What is the total amount each customer spent at the restaurant?

select customer_id, SUM(price) As total_price
from
(select s.customer_id,s.product_id,m.price
from sales s
join menu m ON s.product_id=m.product_id) as x
group by customer_id
order by total_price desc

--(OR)

Select s.customer_id, sum(m.price) as Tot_Price
from sales s join menu m on s.product_id=m.product_id
group by s.customer_id
order by Tot_Price;

-- 2. How many days has each customer visited the restaurant?

select customer_id,COUNT(order_date) as Visited_days
from sales
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?

With first_bought_item as
(select customer_id,product_id, ROW_NUMBER() over(partition by customer_id order by order_date asc) as Rnk
from sales) 
select * from first_bought_item 
where Rnk=1

--OR

select customer_id,product_id
from
(select customer_id,product_id, ROW_NUMBER() over(partition by customer_id order by order_date asc) as Rnk
from sales) as x
where Rnk=1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

with most_purchased_item as
(select m.product_name, COUNT(s.product_id) as most_cnt from sales s
join menu m ON s.product_id=m.product_id
group by product_name)
select * from most_purchased_item where most_cnt=(select MAX(most_cnt) from most_purchased_item);

-- 5. Which item was the most popular for each customer?

with cte as
		(select customer_id, product_id, COUNT(product_id) as cnt 
		from sales
		group by customer_id, product_id )

select customer_id, product_id, cnt from
(select *, ROW_NUMBER() over(partition by customer_id order by cnt desc) as Rnk
from cte) as x
where Rnk=1;

--OR

with cte as
		(select customer_id, product_id, COUNT(product_id) as cnt 
		from sales
		group by customer_id, product_id )

select customer_id, product_id, cnt from
(select *, ROW_NUMBER() over(partition by customer_id order by cnt desc) as Rnk
from cte) as x
where Rnk=1;

-- 6. Which item was purchased first by the customer after they became a member?

with first_purch as
(select mem.customer_id,s.order_date, m.product_name
from sales s join menu m on s.product_id=m.product_id join members mem on s.customer_id=mem.customer_id 
where s.order_date>mem.join_date),

cte as 
( select *, RANK() over(partition by customer_id order by order_date) as Rnk
from first_purch)

select customer_id, product_name, order_date
from cte
where Rnk=1

-- 7.  Which item was purchased just before the customer became a member?

with first_purch as
(select mem.customer_id,s.order_date, m.product_name
from sales s join menu m on s.product_id=m.product_id join members mem on s.customer_id=mem.customer_id 
where s.order_date<=mem.join_date),

cte as 
( select *, RANK() over(partition by customer_id order by order_date desc) as Rnk
from first_purch)

select customer_id, product_name, order_date
from cte
where Rnk=1

--8.What is the total items and amount spent for each member before they became a member?

with cte as
(select s.customer_id,s.product_id, m.product_name, m.price
from sales s join menu m on s.product_id=m.product_id join members mem on s.customer_id=mem.customer_id
where s.order_date<mem.join_date) 

select customer_id, COUNT(product_id) as Total_Items, sum(price) As Tot_amount
from cte    
group by customer_id;

--OR

select customer_id, COUNT(product_id) as Total_Items, sum(price) As Tot_amount
from
(select s.customer_id,s.product_id, m.product_name, m.price
from sales s join menu m on s.product_id=m.product_id join members mem on s.customer_id=mem.customer_id
where s.order_date<mem.join_date) as x
group by customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id, SUM(points) as Total_points
from
(select *, case when product_name='sushi' then price*2 else price*2 end as points
from
(select s.customer_id, m.product_name, m.price
from sales s join menu m on s.product_id=m.product_id) as x) as y
group by customer_id




































































