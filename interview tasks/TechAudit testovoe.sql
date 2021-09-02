create database audit;

use audit;

create table tt (N INT, id_TT INT, name_TT varchar(40), Статус varchar(10),tt_format INT, region_tt varchar(20), city_tt varchar(20));

insert into tt values 
(24574, 14858, '24574МТ_Ленинградское', 'Открыт', 2, 'Москва', 'Москва'),
(24579, 14863, '24579ДС_Кавказский', 'Открыт', 1, 'Москва', 'Москва'),
(24580,	14864,	'24580ДС_Вшк_ТПЗАлтуфьево',	'Закрыт',	2,	'МО',	'МО'),
(22566,	12872,	'22566М_Ленинградский',	'Закрыт',	2,	'Регионы',	'Тверь'),
(24805,	15094,	'24805ДС_Лобачевского',	'Открыт',	3,	'Регионы',	'Тамбов');

select * from tt;

create table dt (Date_tt date, id_tt INT, summa float);

insert into dt values
('2021-06-22',	14858,	4300000.52),
('2021-06-22',	14863,	1500000.38),
('2021-06-22',	15094,	1300000.50),
('2021-06-23',	14858,	3200000.88),
('2021-06-23',	14863,	1700000.63),
('2021-06-23',	15094,	1400000.25),
('2021-06-24',	14858,	4000000.10),
('2021-06-24',	14863,	1664073.88),
('2021-06-24',	15094,	1342476.25);

select * from dt;

create table tt_format_project (tt_format INT, descr_format varchar(20)); 

insert into tt_format_project values
(1,	'ВкусВилл'),
(2,	'Вкус вилл GO'),
(3,	'Минимаркет');

select * from tt_format_project;

create table Checks (ShopNo INT, CloseDate date, BaseSum float, order_id INT); 

insert into Checks values
(24805,	'30.05.2021',	1172.17,	26160002),
(24579,	'30.05.2021',	1175.55,	26160007),
(24805,	'30.05.2021',	410,	26160008),
(24579,	'30.05.2021',	1247.7,	26160005),
(24805,	'30.05.2021',	1563.14,	26160004),
(24579,	'30.05.2021',	56,	NULL),
(24579,	'30.05.2021',	25.2,	NULL),
(24805,	'30.05.2021',	167.6,	NULL),
(24805,	'30.05.2021',	79,	NULL),
(24579,	'30.05.2021',	79,	NULL);


select * from Checks;

--1 zapros
SELECT        
        region_tt,
        count(Distinct tt.id_tt) as cnt_tt
FROM tt
INNER JOIN dt 
        on tt.id_tt = dt.id_tt
where date_tt >= '2021-06-23'
        and date_tt < '2021-07-01'
    and name_TT LIKE '%ДС_%'
group by 
        region_tt
;
SELECT        
        *, region_tt
FROM tt
INNER JOIN dt 
        on tt.id_tt = dt.id_tt
where name_TT LIKE '%ДС_%' and date_tt < '2021-07-01' and date_tt >= '2021-06-23' and region_tt = 'Москва'


--2 zapros
DECLARE @date_begin DATE, @date_end DATE
SET @date_begin = '2021-06-17'
SET @date_end = '2021-06-30'

IF OBJECT_ID('tempdb..#city_tt') IS NOT NULL DROP TABLE #city_tt

SELECT DISTINCT
region_tt,
CASE 
        WHEN region_tt = 'Москва' THEN 'Москва'
        WHEN region_tt = 'МО' THEN 'МО'
        WHEN region_tt = 'Санкт-Петербург' THEN 'Санкт-Петербург'
        WHEN region_tt = 'Ленинградская область' THEN 'Ленинградская область'
ELSE city_tt END city,
N 
into #city_tt
FROM dt (nolock)
LEFT JOIN tt ON tt.id_TT = dt.id_tt
LEFT JOIN tt_format_project ttf ON ttf.tt_format = tt.tt_format
WHERE 
 Summa > 0 AND
 date_tt BETWEEN @date_begin AND @date_end
AND descr_format IN ('Айс', 'Вкус вилл GO', 'ВкусВилл', 'Глобо', 'Жук', 'Шмель')

SELECT 
region_tt,
city,
SUM(basesum) summ_total,
SUM(CASE WHEN ISNULL(order_id, 0) <> 0 THEN basesum END) summ_onl,
COUNT(basesum) qty_total,
COUNT(CASE WHEN ISNULL(order_id, 0) <> 0 THEN basesum END) qty_onl
FROM Checks (nolock) ch
INNER JOIN #city_tt ct ON ch.ShopNo = ct.N
WHERE CAST(CloseDate AS DATE) BETWEEN '2021-04-01' AND '2021-06-30'
GROUP BY 
        region_tt,
        city
ORDER BY 
        region_tt,
        city
		;


select * from tempdb..sysobjects;

select * from #city_tt;

-- my querries

--querry 1 ready!

SELECT TOP 1 (SUM(CASE descr_format WHEN 'ВкусВилл' then summa else 0 end) OVER(partition BY descr_format))/(SUM(summa) over())*100
FROM dt
	inner join tt ON dt.id_tt = tt.id_TT
	inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format
ORDER BY 1 DESC

SELECT avg(qwe)
FROM (SELECT descr_format, (SUM(summa) over(partition BY descr_format))/ (sum(summa) over()) * 100 AS qwe
	FROM dt
		inner join tt ON dt.id_tt = tt.id_TT
		inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format) asd
GROUP BY descr_format
HAVING descr_format = 'ВкусВилл'

SELECT TOP 1 qwe as DolyaViruchki
FROM (SELECT descr_format, (SUM(summa) OVER(partition BY descr_format))/ (SUM(summa) OVER()) * 100 AS qwe
	FROM dt
		inner join tt ON dt.id_tt = tt.id_TT
		inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format) asd
WHERE descr_format = 'ВкусВилл'

--querry 2

SELECT COUNT(CASE WHEN  order_id IS NULL then 1 else NULL end)/COUNT(CASE WHEN  order_id IS NOT NULL then 1 else NULL end) * 100 AS onVSoff_amount
, SUM(CASE WHEN  order_id IS NULL then summa else NULL end)/SUM(CASE WHEN  order_id IS NOT NULL then summa else NULL end)* 100 AS onVSoff_sum
FROM dt
	INNER JOIN tt ON dt.id_tt = tt.id_TT
	INNER JOIN tt_format_project ttf ON ttf.tt_format = tt.tt_format
	INNER JOIN Checks ON Checks.ShopNo = tt.N

SELECT *
FROM dt
	left join tt ON dt.id_tt = tt.id_TT
	left join tt_format_project ttf ON ttf.tt_format = tt.tt_format

SELECT descr_format, SUM(summa) over(partition BY descr_format )
FROM dt
	inner join tt ON dt.id_tt = tt.id_TT
	inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format

SELECT  (SUM(summa) over(partition BY descr_format))/ (sum(summa) over()) * 100
FROM dt
	inner join tt ON dt.id_tt = tt.id_TT
	inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format
HAVING descr_format = 'ВкусВилл'


SELECT  sum(summa)
FROM dt
	inner join tt ON dt.id_tt = tt.id_TT
	inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format

SELECT avg(qwe)
FROM (SELECT descr_format, (SUM(summa) over(partition BY descr_format))/ (sum(summa) over()) * 100 AS qwe
	FROM dt
		inner join tt ON dt.id_tt = tt.id_TT
		inner join tt_format_project ttf ON ttf.tt_format = tt.tt_format) asd
GROUP BY descr_format
HAVING descr_format = 'ВкусВилл'



CREATE TABLE tree (id INT, parent_id INT); 

insert into tree values 
(2, 1), (3, 1), (6, 1), (4, 3), (5, 3);

SELECT * FROM tree;

SELECT id
FROM tree
WHERE id NOT IN (SELECT distinct parent_id from tree)