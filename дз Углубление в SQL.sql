create table country(
	country_id serial primary key,
	country varchar(20) not null
);

create table language(
	language_id serial primary key,
	language varchar(20) not null
);

create table nationality(
	nationality_id serial primary key,
	nationality varchar(20) not null
);

create table country_language(
	country_id integer references country(country_id),
	language_id integer references language(language_id),
	primary key(country_id, language_id)
);

create table country_nationality(
	country_id integer references country(country_id),
	nationality_id integer references nationality(nationality_id),
	primary key(country_id, nationality_id)
);

insert into country(country)
values
	('Russia'),
	('USA'),
	('Italy'),
	('Spain'),
	('Canada');

insert into language(language)
values
	('Russian'),
	('English'),
	('Italian'),
	('Spanish'),
	('French');

insert into nationality(nationality)
values
	('Russian'),
	('American'),
	('Italian'),
	('Spaniard'),
	('Frenchman');

insert into country_language(country_id, language_id)
values
	(1, 1),
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 2),
	(5, 5);

insert into country_nationality(country_id, nationality_id)
values
	(1, 1),
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 2);

--доп 2
alter table country add column update_time timestamp;
alter TABLE country ALTER COLUMN update_time set default CURRENT_TIMESTAMP;
alter table country_language add column verified boolean;
alter TABLE country_language ALTER COLUMN verified set default false;
alter table country add column texts_of_national_anthems text[];

--доп 1

--краткая записсь
create table test2(
	 main_id serial primary key,
	 second_id integer references test1(id)
);

--для столбцов существующей таблицы
alter table test3 foreign key(second_id) references test1(id);


