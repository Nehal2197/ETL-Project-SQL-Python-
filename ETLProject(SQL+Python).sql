
-- find top 10 highest revenue generating products

select top 10 product, sum(turnover) as sales
from df_sales group by product
order by sales desc;

--find top 5 highest selling products in each category

select * from(
select categorie, product, sum(turnover) as sales,rank() over(partition by categorie order by sum(turnover) desc) as rnk
from df_sales group by categorie,product)a
where rnk<=5;


--find month over month growth comparision between years 2018,2019

with cte as(
select year(order_date) as order_year, month(order_date) as order_month, sum(turnover) sales
from df_sales group by year(order_date), month(order_date)
)
select order_month,
       sum(case when order_year=2018 then sales else 0 end) as sales_2018,
	   sum(case when order_year=2019 then sales else 0 end) as sales_2019
from cte
group by order_month
order by order_month


--what is the highest selling month for each category

with cte as(
select format(order_date,'YYYY-MM') as order_year_month, categorie, sum(turnover) as sales
from df_sales group by categorie,format(order_date,'YYYY-MM')
)
select * from (
select *, row_number() over(partition by categorie order by sales desc)
as rnk from cte)a
where rnk=1;


-- which categorie has the highest growth by profit in jan,2020 compare to jan,2019 

with cte as(
select categorie,year(order_date) as order_year,month(order_date) as order_month , sum(turnover) sales
from df_sales group by categorie,year(order_date),month(order_date)
)
,
cte2 as(select categorie,
       round(sum(case when order_year=2019 and order_month=1 then sales else 0 end),0) as sales_2019,
	   round(sum(case when order_year=2020 and order_month=1 then sales else 0 end),0) as sales_2020
from cte
group by categorie)
select *, (sales_2019-sales_2020)*100/sales_2019 as growth_percentage from cte2;
 