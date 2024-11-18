
/* ALL THE SOLUTIONS HAVE BEEN DONE USING MY SQL WORKBENCH AND NOT MS SQL SERVER */

/***CASE STUDY 1: RETAIL STUDY **/

create database retail_study;
use  retail_study;

select * from customer;
select * from transactions;
select * from prod_cat_info;

/******DATA PREPARATION***************/

/* Q1. What is the total number of rows in each of the 3 tables in the database*/

SELECT 'total_customers' AS table_name, COUNT(*) as total_count FROM customer 
UNION ALL
SELECT 'total_transactions' AS table_name, COUNT(*)total_count FROM transactions
UNION ALL
SELECT 'total_product_category' AS table_name, COUNT(*)total_count FROM prod_cat_info;



/* Q2. What is the total number of transactions that have a return?*/
select count(cust_id) as total_no_of_transactions from transactions where total_amt<0;

/* Q3. As you would have noticed, the dates provided across the datasets are not in correct format. As first steps, please convert
the date variables into proper date formats */


select str_to_date(replace(DOB, '/',"-"), "%d-%m-%Y") as DOB, str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y") as tran_date from customer, transactions;



/* Q4. What is the time range of transaction data available for analysis? Show the output in number of days, months and years
simultaneously in different columns.*/

select max(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') )as max_date, 
min(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') )as min_date,
timestampdiff(year, min(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') ), max(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') )) as years,
timestampdiff(month, min(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') ), max(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') )) as months,
timestampdiff(day, min(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') ), max(str_to_date(replace (tran_date, '/','-'), '%d-%m-%Y') )) as days
from transactions;

select str_to_date(replace(tran_date, '/',"-"),"%d-%m-%Y") as tran_date,
timestampdiff(year, str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y"), now()) as years, 
timestampdiff(month, str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y"), now())%12 as months, 
timestampdiff(day, str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y"), now())%30.4375 as days
from transactions;


/*Q5. Which product category does the sub-category "DIY" belong to?*/

select prod_cat from prod_cat_info where prod_subcat="DIY";





/****************DATA ANALYSIS************/
/* Q1. Which channel is most frequently used for transactions?*/

select Store_type, count(transaction_id) as count_of_channels from transactions group by Store_type order by count_of_channels desc limit 1;


/* Q2. What is the count of male and female customers in the database?*/


select gender, count(gender) as count from customer where gender in ('M', 'F') group by(gender);




/* Q3. From which city do we have maximum number of customers and how many? */

select city_code, count(city_code) as num_of_customer from customer group by (city_code) order by num_of_customer desc limit 1 ;


/* Q4. How many sub categories are there under Books category */


select prod_cat, count(prod_subcat) as count_of_subcategories from prod_cat_info where prod_cat = 'Books' group by prod_cat;


/* Q5. What is the maximum quantity of products ever ordered?*/
select max(Qty) as max_quantity from transactions;

/* Q6. What is the net total revenue generated in categories Electronics and Books?*/

select prod_cat as category, sum(total_amt) as total_revenue from transactions A inner join prod_cat_info B
on  A. prod_subcat_code = B.prod_sub_cat_code and A.prod_cat_code=B.prod_cat_code where B.prod_cat in ("Electronics" ,"Books") group by
prod_cat
union all
select 'COMBINED_TOTAL', sum(total_amt) from transactions A inner join prod_cat_info B
on  A. prod_subcat_code = B.prod_sub_cat_code and A.prod_cat_code=B.prod_cat_code where B.prod_cat in ("Electronics" ,"Books");


select round(sum(total_amt),2) as net_total_revenue 
from transactions A 
inner join prod_cat_info B 
on A.prod_cat_code=B.prod_cat_code and A.prod_subcat_code=B.prod_sub_cat_code
where upper(B.prod_cat) in ("ELECTRONICS", "BOOKS");


/* Q7. How many customers have >10 transactions with us excluding returns */

select count(count_of_transactions) as no_of_customers 
from 
(select count(transaction_id) count_of_transactions 
from transactions where total_amt>0 
group by (cust_id) 
having count_of_transactions>10 ) t1;




/*Q8. What is the combined revenue earned from Electronics and Clothing 
categories from Flagship stores*/

select sum(total_amt) as combined_revenue from transactions A inner join prod_cat_info B on A.prod_cat_code=B.prod_cat_code and A.prod_subcat_code=B.prod_sub_cat_code
where prod_cat in ('Electronics', 'Clothing') and Store_type = 'Flagship store';



select round(sum(total_amt),2) as combined_revenue from transactions A inner join prod_cat_info B
on A.prod_cat_code=B.prod_cat_code and A.prod_subcat_code = B.prod_sub_cat_code
where upper(B.prod_cat) in ('ELECTRONICS', 'CLOTHING') and upper(store_type)= 'FLAGSHIP STORE';



/* Q9. What is the total revenue generated from "Male"  customers in "Electronics" category ? Output should display total revenue
by prod sub-cat */

select C. prod_subcat, round(sum(total_amt), 2) as total_revenue 
from transactions A inner join customer B 
on A.cust_id=B.customer_id inner join prod_cat_info C 
on C.prod_cat_code= A.prod_cat_code 
and C.prod_sub_cat_code = A.prod_subcat_code 
where upper(C.prod_cat)='ELECTRONICS' 
and B.gender='M'
group by  C.prod_subcat;


/* Q10. What is percentage of sales and returns by product sub-category, display only top 5 sub categories in terms of sales*/
select prod_subcat,
	round(sum(case when total_amt>0 then total_amt end ) / (select sum(total_amt) from transactions) * 100 ,2) as '%age of sales',
	round(sum(case when total_amt<0 then total_amt end) / (select sum(total_amt) from transactions)* 100 ,2)as '%age of returns'
from transactions A inner join prod_cat_info B on A.prod_cat_code=B.prod_cat_code and A.prod_subcat_code=B.prod_sub_cat_code
group by prod_subcat order by '%age of sales' desc limit 5;


select
prod_subcat,
round(SUM(cast( case when Qty > 0 then total_amt else 0 end as float))/(select sum(total_amt) from transactions) * 100 ,2) as sales_percentage , 
round(SUM(cast( case when Qty < 0 then total_amt else 0 end as float))/(select sum(total_amt) from transactions) * 100,2) as return_percentage 
from Transactions as T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code and T.prod_subcat_code=P.prod_sub_cat_code
group by P.prod_subcat order by sales_percentage desc limit 5;


/* Q11. For all customers aged between 25 and 35 years find what is the net total revenue generated by these consumers in last 30 days 
of transactions from max transaction date available in the data? */






select cust_id, sum(total_amt) as total_revenue from transactions 
 where cust_id in (select customer_Id from customer where timestampdiff(year, str_to_date(replace(dob, '/',"-"), "%d-%m-%Y"), now()) between 25 and 35 ) 
 and str_to_date(replace(tran_date, '/',"-"),"%d-%m-%Y") between 
timestampadd(day, -30, (select max(str_to_date( replace(tran_date, '/',"-"), "%d-%m-%Y")) from transactions)) and 
(select max(str_to_date( replace(tran_date, '/',"-"), "%d-%m-%Y"))) group by cust_id;



/* Q12. Which product category has seen the maximum value of returns in the last 3 months of transactions ?*/


select prod_cat, sum(case when total_amt<0 then total_amt end) as max_return 
from prod_cat_info A inner join transactions B on A.prod_cat_code=B.prod_cat_code and A.prod_sub_cat_code=B.prod_subcat_code
where str_to_date(replace(tran_date,'/','-'), '%d-%m-%Y') between 
timestampadd(month, -3, str_to_date(replace(tran_date,'/','-'), '%d-%m-%Y')) and str_to_date(replace(tran_date,'/','-'), '%d-%m-%Y')
group by prod_cat order by max_return desc limit 1;
 

select prod_cat, sum(total_amt) as max_value_of_return 
from prod_cat_info A inner join transactions B 
on A.prod_cat_code = B.prod_cat_code and A. prod_sub_cat_code=B.prod_subcat_code where str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y" )
BETWEEN timestampadd(MONTH,-3,(SELECT MAX(str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y" )) FROM TRANSACTIONS))
AND (SELECT MAX(str_to_date(replace(tran_date, '/',"-"), "%d-%m-%Y" )) FROM TRANSACTIONS) 
and TOTAL_AMT < 0  group by prod_cat order by max_value_of_return limit 1;


/* Q13. Which store type sells the maximum products by value of sales amount and by quantity sold?*/


select store_type, sum(total_amt) as max_sales_amt , sum(Qty) as max_quantity
from transactions group by Store_type having sum(total_amt) >= all(Select sum(total_amt) from transactions group by store_type)
and sum(Qty)>=all(select sum(Qty) from transactions group by store_type);




/* Q14. What are the categories for which average revenue is above the overall average?*/



select prod_cat, round(avg(total_amt),2) from prod_cat_info A inner join transactions B on A. prod_cat_code= B.prod_cat_code and 
A.prod_sub_cat_code=B.prod_subcat_code group by prod_cat having avg(total_amt)> (select avg(total_amt) from transactions) ;


/*Q15. Find the average and total revenue by each sub category for the categories which are among top 5 categories in terms of quantity sold*/


select prod_subcat, avg(total_amt) as average_amt, sum(total_amt) as total_revenue from prod_cat_info A inner join transactions B on 
A. prod_cat_code= B.prod_cat_code and A.prod_sub_cat_code=B.prod_subcat_code where prod_cat in 
(select * from (select  prod_cat from prod_cat_info A inner join transactions B on A. prod_cat_code= B.prod_cat_code and 
A.prod_sub_cat_code=B.prod_subcat_code group by prod_cat order by sum(Qty) desc limit 5)t1) group by prod_subcat;




select prod_subcat, avg(B.total_amt) as average_revenue, sum(B.total_amt) as total_revenue
 from  prod_cat_info A inner join transactions B on A. prod_cat_code= B.prod_cat_code and 
A.prod_sub_cat_code=B.prod_subcat_code where prod_cat in 
(select* from(select prod_cat from prod_cat_info A inner join transactions B on A. prod_cat_code= B.prod_cat_code and 
A.prod_sub_cat_code=B.prod_subcat_code group by prod_cat order by sum(Qty) desc limit 5)t1)
group by prod_cat, prod_subcat;



