-- задача 1
select 
	a.city
from 
	airports a
group by 
	a.city
having
	count(a.airport_code) > 1;

--задача 2
select 
	f.departure_airport airport
from 
	flights f
where f.aircraft_code in
	(
		select 
			a.aircraft_code
		from 
			aircrafts a 
		where
			a."range" = (select max("range") from aircrafts) 
	) --создание таблицы с кодами самолетов с максимальной дальностью
group by
	f.departure_airport;
	
--адача 3

select 
	f.flight_id, f.actual_departure - f.scheduled_departure
from 
	flights f 
where
	f.actual_departure notnull
order by
	f.actual_departure - f.scheduled_departure desc
limit 10;

--задача 4

select 
	b.book_ref
from 
	bookings b 
	left join tickets t on b.book_ref = t.book_ref --присоединение билетов к броням 
	left join boarding_passes bp on t.ticket_no = bp.ticket_no --присоединение посадочных к билетам
where bp.boarding_no is null; --оставляем только те строки, где к брони не присоединился посадочный

-- задача 5

select 
	f.flight_id, t1.noumber_of_seats - coalesce(t2.ocupied, 0) free_seats, round((t1.noumber_of_seats - coalesce(t2.ocupied, 0)) / t1.noumber_of_seats::numeric, 2) * 100 percentage, sum(coalesce(t2.ocupied, 0)) over(partition by f.departure_airport, f.actual_departure::date order by f.actual_departure),
	f.actual_departure::date, f.departure_airport 
from 
	flights f 
	left join 
	(
		select
			tf.flight_id, count(tf.ticket_no) ocupied
		from 
			ticket_flights tf 
		group by
			tf.flight_id 
	) t2 on t2.flight_id = f.flight_id --отношение рейс, количество занятых мест
	left join 
	(
		select
		a.aircraft_code, count(s.seat_no) noumber_of_seats
		from 
			aircrafts a
		left join seats s on s.aircraft_code = a.aircraft_code 
		group by 
			a.aircraft_code 
	) t1 on t1.aircraft_code = f.aircraft_code -- отношение модель самолета, количество мест
where 
	f.status = 'Departed' or f.status = 'Arrived'; --рассматриваем только те самолеты, которые уже вылетели

-- задача 6

select 
	f.aircraft_code, round(count(f.flight_id)::numeric / (select count(f2.flight_id) from flights f2), 2) * 100 percentage
from 
	flights f 
group by
	f.aircraft_code;
	
-- задача 7

with cte_fare as --создаем CTE с id рейса, условий места, минимальной и максимальной стоимостью
(
	select 
		tf.flight_id, tf.fare_conditions, min(amount), max(amount)
	from 
		ticket_flights tf  
	group by 
		tf.flight_id, tf.fare_conditions
)
select 
	t1.flight_id
from 
(
	select 
		c1.flight_id, c1.max, c2.min
	from 
		cte_fare c1
		left join cte_fare c2 on c1.flight_id = c2.flight_id
	where c1.fare_conditions = 'Economy' and c2.fare_conditions = 'Business'--объединяем два раза вызваную CTE по id рейса для сравнения цен в экономе и бизнесе
) t1-- отношение из id рейса, максимальной цены эконома, минимальной цены бизнеса
where t1.max > t1.min;

--задача 8

create view cities_without_flights as
(
	select 
		a1.city city1, a2.city city2
	from 
		airports a1, airports a2 --Декартово произведение
	where
		a1.city <> a2.city --убираем диагональные элементы
	except-- изключае отношение из пар городов, между которыми существуют рейсы
	select 
		r.departure_city, r.arrival_city 
	from 
		routes r
);--создал представление т.к. требавалось в задании, как использовать его по другому, не придумал

select 
	*
from 
	cities_without_flights cwf

	
-- задача 9

select
	r.flight_no, round(6371 * acos(sind(a2.latitude) * sind(a3.latitude) + cosd(a2.latitude) * cosd(a3.latitude) * cosd(a2.longitude - a3.longitude))) distance, a."range" aircraft_range
from 
	routes r 
	left join aircrafts a on a.aircraft_code = r.aircraft_code --присоединяю к представлению отношения с информацией о координатах аэропортов и дальности полета самолетов
	left join airports a2 on a2.airport_code = r.departure_airport
	left join airports a3 on a3.airport_code = r.arrival_airport
	
	
