select 
	*, row_number() over(partition by customer_id order by rental_date)
from 	
	rental re;
	
with cte_film as
(
	select 
		r.customer_id, f.film_id 
	from 
		rental r 
		join inventory i on r.inventory_id = i.inventory_id 
		join film f on i.film_id = f.film_id 
	where 
		'Behind the Scenes' = any(f.special_features)
	group by 
		r.customer_id, f.film_id
)
select 
	t1.customer_id, count(t1.film_id) noumber
from 
	cte_film t1
group by 
	t1.customer_id
order by 
	t1.customer_id;
	
create materialized view
	number_of_behind_the_scenes_by_customer
as
(
	with cte_film as
	(
		select 
			r.customer_id, f.film_id 
		from 
			rental r 
			join inventory i on r.inventory_id = i.inventory_id 
			join film f on i.film_id = f.film_id 
		where 
			'Behind the Scenes' = any(f.special_features)
		group by 
			r.customer_id, f.film_id
	)
	select 
		t1.customer_id, count(t1.film_id) noumber
	from 
		cte_film t1
	group by 
		t1.customer_id
	order by 
		t1.customer_id
)
with no data;

refresh materialized view number_of_behind_the_scenes_by_customer;

--второй метод поиска
with cte_film as
(
	select 
		r.customer_id, f.film_id, unnest(f.special_features) features
	from 
		rental r 
		join inventory i on r.inventory_id = i.inventory_id 
		join film f on i.film_id = f.film_id 
	group by 
		r.customer_id, f.film_id
)
select 
	t1.customer_id, count(t1.film_id) noumber
from 
	cte_film t1
where
	t1.features like '%Behind the Scenes%'
group by 
	t1.customer_id
order by 
	t1.customer_id

--третий метод
with cte_film as
(
	select 
		r.customer_id, f.film_id, f.special_features
	from 
		rental r 
		join inventory i on r.inventory_id = i.inventory_id 
		join film f on i.film_id = f.film_id 
	group by 
		r.customer_id, f.film_id
)
select 
	t1.customer_id, count(t1.film_id) noumber
from 
	cte_film t1
where
	'Behind the Scenes' = any(t1.special_features)
group by 
	t1.customer_id
order by 
	t1.customer_id
	
--доп задание
--explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

/*
 Unique  (cost=8598.88..8599.22 rows=46 width=44) (actual time=74.784..75.815 rows=600 loops=1)
  ->  Sort  (cost=8598.88..8598.99 rows=46 width=44) (actual time=74.782..75.071 rows=8632 loops=1) МНОГО ВРЕМЕНИ НА СОРТИРОВКУ
        Sort Key: (count(r.inventory_id) OVER (?)) DESC, ((((cu.first_name)::text || ' '::text) || (cu.last_name)::text))
        Sort Method: quicksort  Memory: 1058kB
        ->  WindowAgg  (cost=8596.57..8597.61 rows=46 width=44) (actual time=60.322..64.648 rows=8632 loops=1)
              ->  Sort  (cost=8596.57..8596.69 rows=46 width=21) (actual time=60.305..60.879 rows=8632 loops=1)
                    Sort Key: cu.customer_id
                    Sort Method: quicksort  Memory: 1057kB
                    ->  Nested Loop Left Join  (cost=8211.35..8595.30 rows=46 width=21) (actual time=20.379..56.040 rows=8632 loops=1)
                          ->  Hash Right Join  (cost=8211.07..8581.70 rows=46 width=6) (actual time=20.349..29.512 rows=8632 loops=1)
                                Hash Cond: (r.inventory_id = inv.inventory_id)
                                ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.051..2.400 rows=16044 loops=1)
                                ->  Hash  (cost=8210.50..8210.50 rows=46 width=4) (actual time=20.286..20.287 rows=2494 loops=1)
                                      Buckets: 4096 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 120kB
                                      ->  Subquery Scan on inv  (cost=76.50..8210.50 rows=46 width=4) (actual time=1.250..19.185 rows=2494 loops=1)
                                            Filter: (inv.sf_string ~~ '%Behind the Scenes%'::text)
                                            Rows Removed by Filter: 7274
                                            ->  ProjectSet  (cost=76.50..2484.25 rows=458100 width=710) (actual time=1.242..15.848 rows=9768 loops=1)
                                                  ->  Hash Full Join  (cost=76.50..159.39 rows=4581 width=63) (actual time=1.231..5.234 rows=4623 loops=1)
                                                        Hash Cond: (i.film_id = f.film_id)
                                                        ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.039..0.988 rows=4581 loops=1)
                                                        ->  Hash  (cost=64.00..64.00 rows=1000 width=63) (actual time=1.181..1.181 rows=1000 loops=1)
                                                              Buckets: 1024  Batches: 1  Memory Usage: 104kB
                                                              ->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=63) (actual time=0.041..0.634 rows=1000 loops=1)
                          ->  Index Scan using customer_pkey on customer cu  (cost=0.28..0.30 rows=1 width=17) (actual time=0.002..0.002 rows=1 loops=8632) МНОГО ВРЕМЕНИ НА ПРОВЕРКУ УСЛОВИЯ ЗА СЧЕТ БОЛЬШОГО РАЗМЕРА ТАБЛИЦЫ ren
                                Index Cond: (r.customer_id = customer_id)
Planning time: 1.228 ms
Execution time: 76.372 ms
*/
explain analyze 
with cte_film as
(
	select 
		r.customer_id, f.film_id 
	from 
		rental r 
		join inventory i on r.inventory_id = i.inventory_id 
		join film f on i.film_id = f.film_id 
	where 
		'Behind the Scenes' = any(f.special_features)
	group by 
		r.customer_id, f.film_id
)
select 
	t1.customer_id, count(t1.film_id) noumber
from 
	cte_film t1
group by 
	t1.customer_id
order by 
	t1.customer_id
	
/*
 Sort  (cost=961.11..961.61 rows=200 width=10) (actual time=10.419..10.435 rows=599 loops=1) сортировка конечной таблицы
  Sort Key: t1.customer_id
  Sort Method: quicksort  Memory: 53kB
  CTE cte_film
    ->  HashAggregate  (cost=649.35..735.67 rows=8632 width=6) (actual time=7.075..8.006 rows=8493 loops=1) группировка таблицы
          Group Key: r.customer_id, f.film_id
          ->  Hash Join  (cost=211.30..606.19 rows=8632 width=6) (actual time=1.073..5.656 rows=8608 loops=1) объединение таблиц инвенторя и фильмов
                Hash Cond: (i.film_id = f.film_id)
                ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (actual time=0.781..3.886 rows=16044 loops=1) объединение таблиц проката и инвенторя
                      Hash Cond: (r.inventory_id = i.inventory_id)
                      ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.009..0.778 rows=16044 loops=1) считывание таблицы 'rental'
                      ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=0.749..0.749 rows=4581 loops=1) запись таблицы с инвентарем
                            Buckets: 8192  Batches: 1  Memory Usage: 234kB
                            ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.008..0.331 rows=4581 loops=1) считывание таблицы 'inventory'
                ->  Hash  (cost=76.50..76.50 rows=538 width=4) (actual time=0.289..0.289 rows=538 loops=1) запись таблицы с фильмами в память
                      Buckets: 1024  Batches: 1  Memory Usage: 27kB
                      ->  Seq Scan on film f  (cost=0.00..76.50 rows=538 width=4) (actual time=0.016..0.237 rows=538 loops=1) считывание таблицы 'film' с фильтром по 'special_features'
                            Filter: ('Behind the Scenes'::text = ANY (special_features))
                            Rows Removed by Filter: 462
  ->  HashAggregate  (cost=215.80..217.80 rows=200 width=10) (actual time=10.294..10.341 rows=599 loops=1) группировка CTE
        Group Key: t1.customer_id
        ->  CTE Scan on cte_film t1  (cost=0.00..172.64 rows=8632 width=6) (actual time=7.077..9.155 rows=8493 loops=1) чтение CTE
Planning time: 0.447 ms
Execution time: 10.920 ms
