/*
Part 1:
Michaella: a and 1 for d
Part 2: 
Michaella: iceberg
*/

/*
Part 1:
Badr : Slice and (i) for d
Part 2: 
Badr: WINDOWING
*/

/*
Part 1:
Aisha: Dice and 1 for d
Part 2: windowing clause
*/




-- Part 1.a 
/*
a. Drill down and roll up. – 2 queries
    i For instance, explore the total number of positive cases in your data mart; drill down to a month (April 2020), and drill down to a specific day.
    ii For instance, explore the total number of resolved cases in your data mart; drill down to a week (first week of April 2020), and drill down to a specific day.
    iii For instance, consider all the unresolved cases in Toronto City, roll up to GTA, and roll up to all data in your data mart.
*/

--i For instance, explore the total number of positive cases in your data mart; drill down to a month (April 2020), and drill down to a specific day.
    
SELECT CAST(D.year AS VARCHAR) as "period_of_time", (SUM(F.resolved) + SUM(F.unresolved) + SUM(F.fatal)) as "positive_cases"
    FROM fact F, date D 
    WHERE F.reported_date_id = D.date_id
    GROUP BY (D.year)
UNION ALL
SELECT CONCAT(D.month_name, ' ', D.year) as "period_of_time", (SUM(F.resolved) + SUM(F.unresolved) + SUM(F.fatal)) as "positive_cases"
    FROM fact F, date D 
    WHERE F.reported_date_id = D.date_id
        AND D.month_name = 'August'
        AND D.year = '2020'
    GROUP BY D.month_name, D.year
UNION ALL
SELECT CAST(D.date AS VARCHAR) as "period_of_time", (SUM(F.resolved) + SUM(F.unresolved) + SUM(F.fatal)) as "positive_cases"
    FROM fact F, date D 
    WHERE F.reported_date_id = D.date_id
        AND D.date = '2020-08-22'
    GROUP BY D.date;


SELECT * FROM DATE;
SELECT * FROM fact;
SELECT COUNT(date_id) AS "Positive cases" FROM date;
SELECT year, month_name, GROUPING(year, month_name), COUNT(date_id) AS "Positive cases" FROM date GROUP BY ROLLUP(year, month_name);

-- ii For instance, explore the total number of resolved cases in your data mart; drill down to a week (first week of April 2020), and drill down to a specific day.

SELECT CAST(D.year AS VARCHAR) as "period_of_time", (SUM(F.resolved)) as "positive_cases"
    FROM fact F, date D 
    WHERE F.reported_date_id = D.date_id
    GROUP BY (D.year)
UNION ALL
SELECT CONCAT(D.month_name, ' ', D.year) as "period_of_time", (SUM(F.resolved)) as "positive_cases"
    FROM fact F, date D 
    WHERE F.reported_date_id = D.date_id
        AND D.month_name = 'August'
        AND D.year = '2020'
    GROUP BY D.month_name, D.year
UNION ALL
SELECT CAST(D.date AS VARCHAR) as "period_of_time", (SUM(F.resolved)) as "positive_cases"
    FROM fact F, date D 
    WHERE F.reported_date_id = D.date_id
        AND D.date = '2020-08-22'
    GROUP BY D.date;




--PART#1-B 

--(i) the number of cases in a specific PHU (resolved, unresolved and fatal) 


SELECT count(NULLIF(resolved,0)) AS resolved, count(NULLIF(unresolved,0)) AS unresolved, count(NULLIF(fatal,0)) as fatal, P.phu_name
FROM fact as F, phu as P
WHERE F.test_facility_id = P.phu_key
GROUP BY (P.phu_name);

--//////////OR//////////////

SELECT count(*), P.phu_name
FROM fact as F, phu as P
WHERE F.test_facility_id = P.phu_key
GROUP BY (P.phu_name);

--(ii) the number cases across the PHUs when a specific special measure was in place 


SELECT count(*) AS num_cases, R.restriction_group_id, P.phu_name
FROM fact as F, restriction_group as R, phu as P
WHERE F.restriction_group_id = R.restriction_group_id and F.test_facility_id = P.phu_key and NOT F.restriction_group_id = 0 
GROUP BY (R.restriction_group_id, P.phu_name)
ORDER BY num_cases DESC;


--(iii) the mobility levels in Ottawa 


SELECT retail_and_recreation, grocery_and_pharmacy, parks, transit_stations, workplaces, residential
FROM mobility_trends
WHERE municipality = 'Ottawa';





--Part 1.c)
--the number of fatal cases during a period of two months in Ottawa and Tooronto:

SELECT d.month_name, p.city, SUM(fatal) FROM fact AS f LEFT JOIN date AS d ON f.reported_date_id=d.date_id LEFT JOIN phu AS p ON f.test_facility_id=p.phu_key 
WHERE (d.month_name='September' OR d.month_name='October' OR d.month_name='August') AND (p.city='Ottawa' OR p.city='Toronto')
GROUP BY d.month_name, p.city;

--the number of resolved cases for 2 regions and their mobility trends for prks and transits, in August

SELECT  d.date, m.parks, m.transit_stations, SUM(resolved) 
FROM fact as f LEFT JOIN mobility_trends as m ON f.loc_id=m.mobility_key LEFT JOIN date as d ON f.reported_date_id=d.date_id
WHERE (m.municipality='Toronto' OR m.municipality='Peel') AND d.month_name='August'
GROUP BY d.date, m.parks, m.transit_stations ORDER BY d.date;




-- Part 1.d 
/*
d. Combining OLAP operations. In these queries, we combine the above‐ mentioned operations. – 3 queries
For instance, we may aim to explore the number of cases 
    i) during different periods of the year, 
    ii) when certain types of measures are in place, 
    iii) for different types of outcomes and weather conditions 
    iv) contrasting mobility levels in Ottawa and Peel, 
    v) comparing sunny versus rainy days, etc.
*/

-- v) comparing snowy versus rainy days, etc.
SELECT * FROM weather;

WITH snow_tbl AS (
	SELECT  W.station_name,
		W.snow, 
		(SUM(F.resolved) + SUM(F.unresolved) + SUM(F.fatal)) as "snow_positive_cases" 
	FROM fact F, weather W
	WHERE F.weather_id = W.weather_key
		AND W.snow = TRUE
	GROUP BY W.station_name, W.snow
), rainy_tbl AS (
	SELECT  W.station_name,
		W.rain, 
		(SUM(F.resolved) + SUM(F.unresolved) + SUM(F.fatal)) as "rainy_positive_cases" 
	FROM fact F, weather W
	WHERE F.weather_id = W.weather_key
		AND W.rain = TRUE
	GROUP BY W.station_name, W.rain
)

SELECT S.station_name, S.snow_positive_cases, R.rainy_positive_cases 
	FROM snow_tbl S, rainy_tbl R
	WHERE S.station_name = R.station_name
    ;


-- ii) number of daily cases when indoor gathering restriction was in place (roll up and slice)

	SELECT d.date, SUM(f.resolved) as sum_resolve FROM
	fact AS f LEFT JOIN date as d ON f.reported_date_id=d.date_id LEFT JOIN restriction_group as rg ON f.restriction_group_id=rg.restriction_group_id
	LEFT JOIN restriction_group_bridge as rb ON rg.restriction_group_id=rb.restriction_group_id LEFT JOIN restriction AS r ON r.restriction_id=rb.restriction_id
	WHERE r.description='Indoor gatherings limited to 10 and outdoor gatherings to 25 people across all regions in the province'
	GROUP BY r.start_date, d.date
	ORDER BY d.date;


--PART#1-D

--(i) number of cases during different periods of the year 


SELECT count(*) AS num_cases, D.month_name
FROM fact as F, date as D
WHERE F.reported_date_id = D.date_id
GROUP BY (D.month_name)
ORDER BY num_cases DESC;






------------------------------------------------------------------------------
-- Part 2
/*
a. Iceberg queries. For instance, find the five days with the highest numbers of resolved outcomes, 
find the location with the highest mobility in terms of visits to parks, to grocery stores and pharmacies, etc.
*/

--five days with the highest numbers of resolved outcomes

WITH resolved_tbl AS (
	SELECT F.reported_date_id, SUM(F.resolved) AS "resolved_cases"
		FROM fact F
		GROUP BY F.reported_date_id
		ORDER BY SUM(F.resolved) DESC 
		FETCH FIRST 5 ROWS ONLY
	) 
SELECT CAST(D.date AS VARCHAR) as "period_of_time", R.reported_date_id, R.resolved_cases
	FROM date D, resolved_tbl R
	WHERE D.date_id = R.reported_date_id;


--Part 2. c) 
-- Window Clause: Compare the number of daily resolved cases in Ottawa to that of the previous and next week

SELECT city,date, daily_resolved, AVG(daily_resolved) OVER W AS movavg  FROM
	(SELECT p.city, d.date, SUM(f.resolved) as daily_resolved
	FROM Fact f, date d, phu  p
	WHERE f.reported_date_id=d.date_id AND f.test_facility_id=p.phu_key AND p.city='Ottawa'
	GROUP BY d.date, p.city) as g
WINDOW W AS (PARTITION BY g.city
ORDER BY g.date
ROWS BETWEEN 1 PRECEDING
AND 1 FOLLOWING)



--PART#2-B

SELECT count(*) AS num_cases, P.phu_name AS phu_name, D.month_name AS month_name,
RANK() OVER   
    (PARTITION BY month_name ORDER BY count(*) DESC) AS Rank
FROM fact as F, phu as P, date as D
WHERE F.test_facility_id = P.phu_key and F.reported_date_id = D.date_id
GROUP BY (D.month_name, P.phu_name)
