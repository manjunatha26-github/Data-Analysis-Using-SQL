SELECT * FROM public.customer

--1. Write an SQL query to find the total sales and total profit for each country.
select country, round(sum(sales::numeric),2)as total_sales, round(sum(profit::numeric),2) as total_profit 
from customer group by country;

--2. Write an SQL query to find the top 3 products with the highest total profit in each country.
select * from (select country,product, round(sum(profit::numeric),2) as total_profit,
row_number() over(partition by country order by sum(profit) desc) as rwn 
from customer group by 1,2) as t1
where rwn<=3

--3. Write an SQL query to find the average discount given for each segment and discount band.
select segment, discount_band,round(avg(discounts::numeric),2) as avg_discount_given 
from customer group by segment, discount_band order by segment, discount_band;

--4. Write an SQL query to find the total sales and total profit for each month in a given year (say, 2014)
select month_name,month_number, round(sum(profit::numeric),2) as total_profit,
round(sum(sales::numeric),2) as total_sales
from customer 
where year=2014 
group by month_name,month_number 
order by month_number;

--5. Write an SQL query to find the most profitable segment in each country.
with cte_t1 as 
(select country, segment, round(sum(profit::numeric),2) as total_profit, 
dense_rank() over(partition by country order by sum(profit) desc) as rnk 
from customer group by country,segment) 
select * from cte_t1 where rnk =1 order by total_profit;

--6. Write an SQL query to find the total units sold and total sales for each discount band across all products and countries.
SELECT discount_band, SUM(units_sold) AS total_units_sold,ROUND(SUM(sales::numeric), 2) AS total_sales
FROM customer
GROUP BY discount_band
ORDER BY total_sales DESC;


--7. Write an SQL query to find the top 2 products with the highest total sales in each month.
WITH monthly_sales AS (
    SELECT month_number,month_name,product,ROUND(SUM(sales::numeric), 2) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY month_number ORDER BY SUM(sales) DESC) AS rnk
        FROM customer
        GROUP BY month_number, month_name, product
)
SELECT month_number, month_name,product,total_sales
FROM monthly_sales
WHERE rnk <= 2
ORDER BY month_number, total_sales DESC;

--8. Write an SQL query to find the profit margin (%) for each product across all countries.
SELECT product,ROUND(SUM(sales::numeric), 2) AS total_sales,
       ROUND(SUM(profit::numeric), 2) AS total_profit,
       round((SUM(profit::numeric) / SUM(sales::numeric) * 100),2) AS profit_margin_Percent
FROM customer
GROUP BY product
ORDER BY profit_margin_Percent DESC;


--9. Write an SQL query to calculate the Year-over-Year (YoY) Profit Growth (%) for each country.
with cte_t1 as 
(select country, year, 
round(sum(profit::numeric),2) as total_profit, 
lag(sum(profit)) over(partition by country order by year) as prev_yr_proj
from customer 
group by country, year 
)
select country, year,total_profit, prev_yr_proj, 
ROUND(((total_profit::numeric - prev_yr_proj::numeric) / NULLIF(prev_yr_proj::numeric, 0)) * 100,2) as YOY_Percentage
from cte_t1 order by country, year;

--10. Write an SQL query to identify countries that had a decline in total sales compared to the previous year.

select * from (select country,year,sum(sales)as total_sales,
lag(sum(sales)) over(partition by country order by year) as prev_year_sales
from customer group by country,year ) as t1
where total_sales > prev_year_sales;

--11. Write an SQL query to find products that have shown a decline in total sales for at least two consecutive Years.
with cte_1 as 
( select product, year, round(sum(sales::numeric),2) as total_sales, 
lag(sum(sales)) over(partition by product order by year) as pre_year_sales 
from customer group by product,year
),
cte_2 as
( select product, year, total_sales, pre_year_sales, 
case when total_sales < pre_year_sales then 1 else 0 end as Pre_sales_true
from cte_1
),
cte_3 as
(select product, year, total_sales, pre_year_sales, 
lag(pre_sales_true) over(partition by product order by year) as pre_cons_true
from cte_2
)
select * from cte_3 where pre_sales_true =1 and pre_cons_true =1 
order by product, year;









