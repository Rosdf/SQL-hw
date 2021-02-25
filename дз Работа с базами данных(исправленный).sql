select 
	c.store_id
from 
	customer c
group by
	c.store_id 
having 
	count(c.customer_id) > 300
order by 
	c.store_id;
	
select 
	c.customer_id , ci.city 
from
	address a
	join customer c on a.address_id = c.address_id
	join city ci on ci.city_id = a.city_id 
order by 
	c.customer_id;


select 
	sta.first_name, sta.last_name, ci.city 
from 
	customer c
	join store s on c.store_id = s.store_id 
	join staff sta on sta.store_id = s.store_id 
	join address a on a.address_id = s.address_id 
	join city ci on ci.city_id = a.city_id 
group by 
	sta.staff_id, ci.city_id 
having 
	count(c.customer_id) > 300

select 
	count(distinct fa.actor_id)
from 
	film_actor fa 
	join film f on f.film_id = fa.film_id 
where 
	f.rental_rate > 2.99; 

 
	
	