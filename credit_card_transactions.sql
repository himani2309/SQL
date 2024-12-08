
--1 write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte as (select sum(amount) as total_spend from credit_card_transactions),
cte1 as (select city, sum(amount) as city_wise_spend from credit_card_transactions group by city)
select top 5 city, city_wise_spend , round(city_wise_spend/(select total_spend from cte) *100, 2) as percentage from cte1
order by city_wise_spend desc



--2 write a query to print highest spend month and amount spent in that month for each card type

with cte as(select card_type, year(transaction_date) as year, month(transaction_date) as month, sum(amount) as total_spend
from credit_card_transactions group by card_type, year(transaction_date), month(transaction_date))
, cte1 as (select *, rank() over (partition by card_type order by total_spend desc) as rn from cte)
select card_type, month, total_spend from cte1 where rn=1


--3 write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as(select *, sum(amount) over (partition by card_type order by transaction_date, transaction_id) as total from credit_card_transactions),
cte1 as (select*, rank() over (partition by card_type order by total asc) as rn from cte where total>=1000000)
select * from cte1 where rn=1


--4 write a query to find city which had lowest percentage spend for gold card type

with cte as (select city, card_type , sum(amount) as total_amount, 
sum(case when card_type = 'Gold' then amount end) as gold_amount
from credit_card_transactions
group by city, card_type)
select top 1 city, sum(gold_amount)* 1.0/sum(total_amount) as gold_ratio from cte
group by city having sum(gold_amount) is not null order by gold_ratio



--5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)


with cte as(select city, exp_type, sum(amount) as expense from credit_card_transactions group by city, exp_type),
cte1 as (select *, rank() over (partition by city order by expense desc) as highest_expense_type,
rank() over (partition by city order by expense asc) as lowest_expense_type from cte)

select city, 
max(case when lowest_expense_type=1 then exp_type end) as lowest_exp_type,
max(case when highest_expense_type=1 then exp_type end)as highest_exp_type
from cte1
group by city order by city


--6 write a query to find percentage contribution of spends by females for each expense type

select exp_type, sum(case when gender='F' then amount else 0 end)*1.0/sum(amount) as percentage from credit_card_transactions  group by exp_type order by percentage desc


--7 which card and expense type combination saw highest month over month growth in Jan-2014


with cte as (select exp_type, card_type, year(transaction_date) as year, month(transaction_date) as month,
sum(amount) as expense from credit_card_transactions 
group by card_type, exp_type, year(transaction_date), month(transaction_date)),
cte1 as (select *, lag(expense, 1) over (partition by exp_type, card_type order by year, month) as prev_expense
from cte)

select top 1 exp_type, card_type, (expense-prev_expense)*1.0 / prev_expense as mom_growth from cte1 where 
prev_expense is not null and
year=14 and month=1 order by mom_growth desc




--8 During weekends which city has highest total spend to total no of transcations ratio 

select top 1 city, sum(amount)/count(1) as ratio from credit_card_transactions where dayname(transaction_date) in
('Sat', 'Sun') group by city order by ratio desc


--9 which city took least number of days to reach its 500th transaction after the first transaction in that city
select * from credit_card_transactions

with cte as (select *, row_number() over (partition by city order by transaction_date) as rn from credit_card_transactions)

select top 1 city, datediff(days, min(transaction_date), max(transaction_date)) as days
from cte where rn=1 or rn=500 group by city 
having count(1)=2
order by days 



