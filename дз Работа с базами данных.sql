select customer_id as CustomerId,
first_name as FirstName,
last_name as LastName
from customer 
where active = 0;

select film_id as FilmId,
title as Title
from film
where release_year = 2006;

select 
	amount,
	payment_date 
from 
	payment 
order by
	payment_date desc
limit 10

SELECT 
	is1.table_name, is1.constraint_name, is2.column_name, is3.data_type 
FROM 
	information_schema.constraint_column_usage is2
	right join information_schema.table_constraints is1 on is1.constraint_name = is2.constraint_name
	left join information_schema.columns is3 on is2.column_name = is3.column_name 
where
	is1.table_schema = 'public' and is1.constraint_type = 'PRIMARY KEY'
order by 
	is1.table_name, is2.column_name;