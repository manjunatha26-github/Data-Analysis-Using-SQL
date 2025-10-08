SELECT * FROM public.retail_sales
ORDER BY transactions_id ASC LIMIT 10;

select * from retail_sales;

select count(*) from retail_sales;

select * from retail_sales 
where transactions_id IS NULL 
or sale_date is null 
or sale_time is null 
or customer_id is null 
or gender is null 
or category is null 
or quantiy is null 
or price_per_unit is null 
or cogs is null 
or total_sale is null; 

delete from retail_sales
where  transactions_id IS NULL 
or sale_date is null 
or sale_time is null 
or customer_id is null 
or gender is null 
or category is null 
or quantiy is null 
or price_per_unit is null 
or cogs is null 
or total_sale is null;

select * from retail_sales;

select count(distinct category) as count_trans from retail_sales;

select transactions_id, price_per_unit
       from retail_sales where price_per_unit >= 500; 

select * from retail_sales order by transactions_id;
	   
select count(*) from retail_sales where mod(transactions_id,2)=1;

select * from 
(select transactions_id, row_number() over(order by transactions_id) as row_num from retail_sales) as row_numgiv
where mod(row_num,2)=0;


select distinct extract(day from sale_date) as year_of from retail_sales order by 1;

select sale_date,transactions_id, row_num from 
(select transactions_id, sale_date,row_number() over(partition by extract(year from sale_date), extract(month from sale_date) order by sale_date desc) as row_num
from retail_sales) as max_date_sales where row_num = 1; 

-- How many sales we have?
select count(*) as total_sales from retail_sales;

-- How many uniuque customers we have ?
select count(distinct customer_id) as uniq from retail_sales;

select * from retail_sales;

-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
select * from retail_sales where sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the
---quantity sold is more than 3 in the month of Nov-2022

select * from retail_sales where category = 'Clothing' and to_char(sale_date,'YYYY-MM')='2022-11' and quantiy >=4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category, sum(total_sale) as total_sales from retail_sales group by category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select round(avg(age),0) as avg_age from retail_sales where category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales where total_sale >1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category, gender, count(transactions_id) as no_of_trans from retail_sales group by category, gender;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
 select * from 
 (select 
 extract(year from sale_date) as year,
 extract(month from sale_date) as month,
 avg(total_sale) as avg_sales,
 rank() over(partition by extract(year from sale_date) order by avg(total_sale) desc) as rnk
 from retail_sales 
 group by 1,2) as t1 where rnk=1;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
select customer_id, sum(total_sale) as sales from retail_sales group by customer_id order by 2 desc limit 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select category, count(distinct customer_id) as count_cust from retail_sales group by 1;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

select * from retail_sales;

with ct_eg as
(select *, case 
			when extract(hour from sale_time) <12 then 'Morning'
			when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
			else 'Evening'
			end as shift from retail_sales) 
select shift, count(*) from ct_eg group by 1;		

--End of Project


