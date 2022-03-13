/* Financial 
/* What about company's revenues (evolution over years and months)


select strftime('%Y', payment_date)as Year, strftime('%m', payment_date) as Month, round(sum(amount),0) as Revenue
from payment 
group by Year, Month
Order by year, month

/* How many rentals are done in different stores?

Select s.store_id as Store, count(r.rental_id) as TimesRented
from store s, rental r
where s.manager_staff_id = r.staff_id
group by 1


/* Customers 
/* How many customers do we have (over time)?

Select strftime('%Y', create_date) || strftime('%m', create_date) as YearMonthCreated, count( distinct customer_id) as NumberOfCustomers
From customer 
group by 1

/* How long has it been since the last purchase (recency)? How many purchases 
has the customer done (frequency)? How much does the customer spend on 
average (monetary value)?


select (date('now') - max(payment_date))  || ' years ago' as LastPurchase, 
'on average: ' || (count(customer_id)/count(distinct customer_id)) as PurchasesPerCustomer, 'on average: ' || round(avg(amount),2) As AmountSpent
from payment


/* Give insight into the tenure of customers (how long are they already with the company)

select 'customers stay with the company on average: ' || avg(date('now') - create_date) || ' years' as CustomerTenure
from customer

/* Where are our customers located and what is our biggest market (sales per 
market)? Note that a market may also be US/Europe/Asia.

select cl.country as TopSellingCountries,  round(sum(amount),0) as Sales, round(100*( sum(pm.amount)/(
select sum(amount)
from payment)),2) || '%' as PercentShare
from customer_list cl, payment pm
where cl.id = pm.customer_id
group by 1
order by 2 desc
limit 10


/* Internal Business Processes 
/*  Give insight into the DVDs that are rented most/least. What are the 
conclusions? You can also create groups of low, average and good performing
actors/categories/..

select f.title, f.rating, round(sum(p.amount),2) as TitleRevenue, Count(f.film_id) as TimesRented
from payment p, rental r, inventory i, film f, film_category fc
where p.rental_id = r.rental_id
and r.inventory_id = i.inventory_id
and i.film_id = f.film_id
and f.film_id = fc.film_id
group by 1
order by 3 desc
limit 10

/* Category selling rating 

select SellingRating, c.name, TimesRented from (
select c.name, round(sum(p.amount),2) as CategoryRevenue, Count(f.film_id) as TimesRented,
case when Count(f.film_id) < 900 then 'Slow Seller'
when Count(f.film_id) >1100 then 'Best Seller'
else 'Medium Seller' end as SellingRating
from payment p, rental r, inventory i, film f, film_category fc, category c
where p.rental_id = r.rental_id
and r.inventory_id = i.inventory_id
and i.film_id = f.film_id
and f.film_id = fc.film_id
and fc.category_id = c.category_id
group by 1
order by 3 desc)
group by SellingRating

/* Are there movies that have no sales?

select film_id
from film
except
select i.film_id
from payment p, rental r, inventory i
where p.rental_id = r.rental_id
and r.inventory_id = i.inventory_id

/* Are there any characteristics related to these movies?:

select film_id
from inventory
where 1 in (
select film_id 
from NoSaleFilms)


/* Employees 
/* There are only a very limited number of employees, 1 related to each store. 
So these analyses may coincide with the ones on the store level. 

select p.staff_id, cl.country
from payment p, rental r, customer c, customer_list cl 
where p.rental_id = r.rental_id
and c.customer_id = cl.id
group by 1,2


select  strftime('%d' ,avg(return_date - rental_date))
from rental
group by staff_id

select film_id, staff_id from(
select f.film_id, count(r.rental_id), r.staff_id
from rental r, inventory i, film f
where r.inventory_id = i.inventory_id
and i.film_id = f.film_id
group by f.film_id
order by 2 desc
limit 3

