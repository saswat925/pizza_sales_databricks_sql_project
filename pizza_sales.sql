        -----PIZZA SALES ANALYSIS -----
use catalog saswat;

use schema pintu;

--check all 4 tables of pizza data
select * from saswat.pintu.order_details;

select * from saswat.pintu.orders;

select * from saswat.pintu.pizza_types;

select * from saswat.pintu.pizzas;

--check raw data for all tables
select count(*) as total_od from  order_details;
---total rows 48620
select count(*) as total_pt from  pizza_types;
---total rows 32
select count(*) as total_o from  orders;
----total rows 21350
select count(*) as total_p from  pizzas;
---total rows 96
         
         -------DATA CLEANING PART----
--first clean order_details table
--check for null values
select * from order_details where order_details_id is null
                                  or order_id is null
                                  or pizza_id is null
                                  or quantity is null;

      --no nulls found 

--check for duplicate values
select count(*) as duplicate_od from order_details group by order_details_id having count(*) > 1;

                               --duplicate no found
  --check for negative values
select * from order_details where quantity < 0;

 --no neagative value found
---check the data type
desc order_details;



----Second clean the orders table
--nul check
select * from orders where order_id is null
                         or date is null or time is null;

--no null found

--check for duplicate values
select count(*) as duplicate_o from orders group by order_id having count(*) > 1;

--no duplicate 
   --data type check
   desc orders;

   
   
   ----Third clean the pizzas table
   --null check
   select * from pizzas where pizza_id is null
                           or pizza_type_id is null
                           or size is null
                           or price is null;

--no null found

--check for duplicate values
select count(*) as duplicate_p from pizzas group by pizza_id having count(*) > 1;

--no duplicate 
   --data type check
   desc pizzas;

   
   
   ----Fourth table clean pizza_types table
   --null check
   select * from pizza_types where pizza_type_id is null
                                 or name is null
                                 or category is null
                                 or ingredients is null;

--no null found

--check for duplicate rows
select count(*) as duplicate_pt from pizza_types group by pizza_type_id having count(*) > 1;

--no duplicate 
   --data type check
   desc pizza_types;

   --one combine table create by joining all 4 tables for better analysis---
   --create table pizza_sales.
   create or replace table pizza_sales as
select od.order_details_id,
       od.order_id,
       od.pizza_id,
  cast(od.quantity as int) as quantity,   ----convert the data type of quantity from bigint to int use cast function
       o.date,
       o.time,
       p.pizza_type_id,
       p.size,
       p.price,
       pt.name,
       pt.category,
       pt.ingredients,
       od.quantity * p.price as total_revenue
from order_details od
join orders o
on od.order_id = o.order_id
join pizzas p
on od.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id;


--check the combine table
select * from pizza_sales;

--check the data type
desc pizza_sales;

--check the total rows
select count(*) as total from pizza_sales;
--total rows 48620

    -------------ANALYSIS PART FROM NEW COMBINE TABLE 'PIZZA_SALES'---------------
   --All Business Kpi
   SELECT
    round(SUM(total_revenue),2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_pizzas_sold,
    -- Average Order Value
   round(SUM(total_revenue) / COUNT(DISTINCT order_id),2) AS avg_order_value,
    -- Average Pizzas Per Order
   round( SUM(quantity) / COUNT(DISTINCT order_id),2) AS avg_pizzas_per_order

FROM pizza_sales;

--Key Business Insights
--Revenue Performance: Generated 817.8K in total revenue from 21,350 orders across the year 2015.
--Customer Behavior:
--Average order value is 38.31 - customers spend moderately per transaction
--Average 2.32 pizzas per order - most orders contain 2-3 pizzas, suggesting small group/family orders
--Sales Volume: Sold nearly 50K pizzas (49,574 units), indicating strong product demand with consistent ordering patterns.

--TOP SELLING PIZZA
 select name as top_selling_pizza, round(sum(total_revenue),2) as total_revenue from pizza_sales
 group by name 
 order by total_revenue desc;

   --insights
   --The top selling pizza is The 'Thai Chicken Pizza' with total revenue 43434.25 

--Lowest selling pizza
select name as top_selling_pizza, round(sum(total_revenue),2) as total_revenue from pizza_sales
 group by name 
 order by total_revenue asc 
 limit 1;

  ---insights
  --The lowest selling pizza is 'The Brie Carre Pizza' with total revenue 11588.5

--CATEGORY ANALYSIS
select category, round(sum(total_revenue),2) as revenue from pizza_sales
group by category
order by revenue desc;
--insights
--Classic pizzas lead with 220K revenue (27% of total), while all four categories perform remarkably evenly within a 26K range, showing no weak performers.
--The tight revenue distribution (194K-220K across categories) indicates a well-balanced menu that successfully appeals to diverse customer preferences without over-reliance on any single category.

--SIZE ANALYSIS
select size, round(sum(total_revenue),2) as revenue from pizza_sales
group by size
order by revenue desc;  
--Insights
--sizes are L,M,S,XL,XXL.
--Large pizzas dominate with 375K revenue (46% of total), while Medium (249K) and Small (178K) sizes also perform strongly, together accounting for 98% of all sales.
--XL and XXL sizes contribute minimally (combined 15K or just 2%), suggesting customers overwhelmingly prefer standard L/M/S sizes over specialty extra-large options.

  -----TIME BASED ANALYSIS--
--Orders by hours, orders peak hour
select hour(time) as hour, count(distinct order_id) as orders from pizza_sales
group by hour
order by hour;
--Insights
--Orders peak during lunch (12-1pm with 5K orders) and dinner hours (5-6pm with 4.7K orders), showing classic bimodal pattern with nearly 70% of daily orders concentrated in these 4 hours.
--Minimal activity before 11am and after 10pm (under 40 orders combined), indicating the business operates primarily during traditional meal times with strong predictable demand windows for staffing optimization.

--Daily Revenue Trend
select date, round(sum(total_revenue),2) as daily_revenue from pizza_sales
group by date
order by date;
--insights
--Daily revenue averages 2.2K with holiday peaks reaching 4.4K (Thanksgiving weekend, July 4th), but collapses to year-low 1.3K during post-Christmas week (Dec 26-30), revealing strong event-driven demand and significant seasonal volatility.

--Monthly Revenue Trend
SELECT 
    MONTH(date) AS month_number,---month number 1,2,3,4,5,6,7,8,9,10,11,12 use month function.
    DATE_FORMAT(date, 'MMMM') AS month_name,---month name January,February,March,April,May,June,July,August,September,October,November,December use date_format function.
    ROUND(SUM(total_revenue),2) AS revenue
FROM pizza_sales
GROUP BY MONTH(date), DATE_FORMAT(date, 'MMMM')
ORDER BY month_number;
--Insights
--July peaks at 72.5K revenue (highest of the year), while summer months (May-July) consistently outperform with 71-72K, driving 13% higher revenue than the weakest quarter (Sept-Oct at 64K average).
--Fall season shows the steepest decline - September through October drop to year's lowest at 64K, followed by partial December recovery, indicating seasonal demand patterns that warrant targeted promotions during slow months.

--By Day of Week Analysis
SELECT 
       DATE_FORMAT(date, 'EEEE') AS day_name,--day name Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday use date_format function.
    ROUND(SUM(total_revenue),2) AS revenue
FROM pizza_sales
GROUP BY day_name
ORDER BY revenue DESC;
--Insights
--Friday leads with 136K revenue (17% of weekly total), while Sunday underperforms at 99K, showing a 37% revenue gap between best and worst days - suggesting Friday date nights drive peak demand while Sunday sees the weakest customer engagement.


--Month + Year (for trend)
SELECT DATE_FORMAT(date, 'MMMM') AS month_name,
    DATE_FORMAT(date, 'yyyy-MM') AS month_year,
    ROUND(SUM(total_revenue),2) AS revenue
FROM pizza_sales
GROUP BY month_year, month_name
ORDER BY revenue DESC;
--Daily revenue averages 2.2K with holiday peaks reaching 4.4K (Thanksgiving weekend, July 4th), but collapses to year-low 1.3K during post-Christmas week (Dec 26-30), revealing strong event-driven demand and significant seasonal volatility.

---Weekend vs Weekday Analysis,, (using case when)
SELECT 
    CASE WHEN DATE_FORMAT(date, 'EEEE') IN ('Saturday', 'Sunday') THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    ROUND(SUM(total_revenue),2) AS revenue
FROM pizza_sales
GROUP BY day_type
ORDER BY revenue DESC;
--Insights
--day_type	revenue
--Weekday	  595474.15
--Weekend	  222385.95
--Weekdays generate nearly 3X more revenue than weekends, indicating a strong weekday bias in customer behavior, possibly due to work schedules or family routines.






