select * from retail_sales;

--10th Oct solve 50 Queries challenge

--1.Find the top 3 categories that generated the highest total sales amount overall.
select category, sum(total_sales) as total from retail_sales group by category order by 2 desc limit 3;

--2. Find the total sales and total quantity sold for each gender and category combination.
--Then, order the results by total sales in descending order.
select category, gender, sum(total_sales) as tot,sum(quantity) as qty from retail_sales group by 1,2 order by 3 desc;

--3.Find the total profit made for each transaction by calculating it as total_sales - cogs,
--and display the transaction_id, customer_id, category, total_sales, cogs, and calculated profit.

select transactions_id, customer_id, category, total_sales, cogs, total_sales - cogs as profit from retail_sales;

--4.Add a new column named profit to the retail_sales table,and then update it with the value oftotal_sales - cogsfor each transaction.
alter table retail_sales add profit int;

update retail_sales set profit=total_sales-cogs;

--5.Find the top 5 customers who have generated the highest total sales.
--Display customer_id, gender, total_sales, and order the results by total sales descending.
select customer_id,gender, sum(total_sales) as tot from retail_sales group by 1,2 order by 3 desc limit 5;

--6.For each category, find the transaction with the highest profit. Display category, transaction_id, customer_id, and profit.
select * from (select category, transactions_id,customer_id, profit, 
rank() over(partition by category order by profit desc) as rnk from retail_sales)
where rnk =1;

--7.Calculate the cumulative total sales for each customer ordered by sale_date.
--Display customer_id, sale_date, total_sales, and cumulative_sales.
select customer_id, sale_date, total_sales, sum(total_sales) over(partition by customer_id order by sale_date) as cum from retail_sales;

--8.For each customer, find the previous transaction’s total_sales using a window function.
--Display customer_id, sale_date, total_sales, and previous_total_sales.

select customer_id, sale_date, total_sales,
lag(total_sales) over(partition by customer_id order by sale_date) as Prev_Sale from retail_sales;

--9. Find the month-wise total sales for each category for the year 2025.
select * from (select category, extract(month from sale_date) as month_num, sum(total_sales) as tot
from retail_sales where extract(year from sale_date) = 2022 group by 1,2 order by 1)As t1 where month_num = 5;

--10. Find the top 3 customers in each category based on their total sales.
select * from (select category, customer_id,sum(total_sales) as tot,
row_number() over(partition by category order by sum(total_sales) desc) as rn from retail_sales group by 1,2)as t1 where rn <=3; 

--11. Find the total number of transactions, total quantity sold, and total sales made by each gender in each month.

select extract(month from sale_date)as mt, gender, count(transactions_id) as tot_trans, 
sum(quantity)as tot_qty, sum(total_sales) as tot_sale from retail_sales group by 1,2 order by 1;

alter table retail_sales rename column transactions_id to transaction_id;


select * from retail_sales where category ilike '%y%';

--12. Find the top-performing gender (based on total profit) in each category. Display the category, gender, and total profit.
select * from (select category, gender,sum(profit) as tot_profit,
row_number() over(partition by category order by sum(profit) desc)as rn from retail_sales group by 1,2) where rn =1;

--13. Find the customers who had no transactions in the last 3 months of 2023.
select customer_id from retail_sales where customer_id not in 
(select customer_id from retail_sales where sale_date between '2023-11-01' and '2023-12-31');

select max(sale_date) from retail_sales;

SELECT DISTINCT customer_id
FROM retail_sales
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM retail_sales
    WHERE sale_date >=(select max(sale_date) from retail_sales) - INTERVAL '3 months'
);

--14. For each category, calculate the average profit per transaction and show only categories with average profit greater than 500.

select category, avg(profit) as avg_profit from retail_sales group by category having avg(profit) >500;

--15. Find the category and month where the profit was the lowest for each year.
select * from 
(select category, extract(year from sale_date) as year,extract(month from sale_date) as month, sum(profit),
row_number() over(partition by category, extract(year from sale_date) order by sum(profit) asc) as prt
from retail_sales group by 1,2,3) as t1 where prt =1;

--16. For each customer, find their first and last transaction date, along with total sales they made.

select customer_id, min(sale_date) as first_trans, max(sale_date) as last_trans, sum(total_sales) total_sales 
from retail_sales group by 1 order by 1;

--17.For each month in 2023,find the category with the highest total profit 
--and also show the customer who contributed the most profit in that category for that month.

with t1 as
(select extract(month from sale_date) as month,category, sum(profit) as sum_profit, 
row_number() over(partition by extract(month from sale_date) order by sum(profit) desc) as rnk 
from retail_sales where extract(year from sale_date) = 2023 group by 1,2),
t2 as
(select extract(month from sale_date) as month,category,customer_id, sum(profit) as sum_profit,
row_number() over(partition by extract(month from sale_date),category order by sum(profit) desc) as cust_rnk 
from retail_sales
where extract(year from sale_date) = 2023 group by 1,2,3)

select t1.month, t1.category, t1.sum_profit, t2.customer_id from t1 inner join t2 on t1.month=t2.month and t1.category=t2.category 
where t1.rnk=1 and cust_rnk=1;

--18. For each category, find the month with the highest total sales, 
--and also show the total number of distinct customers who purchased in that month-category combination.

with cte1_exp as 
(select category, extract(month from sale_date) as month,count(distinct customer_id) as dist_cust, sum(total_sales) as tot_sales, 
row_number() over(partition by category order by sum(total_Sales) desc) as rn 
from retail_sales group by 1,2)
select * from cte1_exp where rn =1;

--19. Write a query to find the running total of sales for each category month by month, ordered by date.

SELECT 
  category,sale_date,total_sales,
  SUM(total_sales) OVER (PARTITION BY category ORDER BY sale_date) AS running_total
FROM retail_sales;








