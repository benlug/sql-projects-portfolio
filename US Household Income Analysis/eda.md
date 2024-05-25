# US Household Income EDA

```sql
USE us_household_income;

SELECT *
FROM ushouseholdincome;

SELECT *
FROM ushouseholdincome_statistics;
```

Calculate the total land and water area for each state.
```sql
SELECT
	State_Name, 
    SUM(ALand) AS total_land, 
    SUM(AWater) AS total_water
FROM
	ushouseholdincome
GROUP BY
	State_Name
ORDER BY
	SUM(ALand) DESC;
```

Calculate the total land and water area for each state.
```sql
SELECT
	State_Name, 
    SUM(ALand) AS total_land, 
    SUM(AWater) AS total_water
FROM
	ushouseholdincome
GROUP BY
	State_Name
ORDER BY
	SUM(AWater) DESC;
```

Calculate the total land area for the top 10 states
```sql
SELECT
	State_Name, 
    SUM(ALand) AS total_land, 
    SUM(AWater) AS total_water
FROM
	ushouseholdincome
GROUP BY
	State_Name
ORDER BY
	SUM(ALand) DESC
LIMIT 10;
```

```sql
SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM 
	ushouseholdincome u
INNER JOIN 
	ushouseholdincome_statistics us
ON 
	u.id = us.id
WHERE 
	us.Mean != 0;
```

Calculate the average mean and median household income for each state
```sql
SELECT u.State_Name, ROUND(AVG(Mean), 2) AS avg_mean, ROUND(AVG(Median), 2) AS avg_median
FROM 
	ushouseholdincome u
INNER JOIN 
	ushouseholdincome_statistics us
ON 
	u.id = us.id
WHERE 
	us.Mean != 0
GROUP BY
	u.State_Name
ORDER BY
	3 DESC
LIMIT 10;
```

Calculate the average mean and median household income for each type
```sql
SELECT u.Type, COUNT(u.Type) AS count_type, ROUND(AVG(Mean), 2) AS avg_mean, ROUND(AVG(Median), 2) AS avg_median
FROM 
	ushouseholdincome u
INNER JOIN 
	ushouseholdincome_statistics us
ON 
	u.id = us.id
WHERE 
	us.Mean != 0
GROUP BY
	u.Type
ORDER BY
	4 DESC
LIMIT 20;
```

Calculate the average mean and median household income for each type with more than 100 records.
```sql
SELECT u.Type, COUNT(u.Type) AS count_type, ROUND(AVG(Mean), 2) AS avg_mean, ROUND(AVG(Median), 2) AS avg_median
FROM 
	ushouseholdincome u
INNER JOIN 
	ushouseholdincome_statistics us
ON 
	u.id = us.id
WHERE 
	us.Mean != 0
GROUP BY
	u.Type
HAVING
	COUNT(u.Type) > 100
ORDER BY
	4 DESC
LIMIT 20;
```

Calculate the average mean and median household income for each city
```sql
SELECT u.State_Name, u.City, ROUND(AVG(Mean), 2) AS avg_mean, ROUND(AVG(Median), 2) AS avg_median
FROM 
	ushouseholdincome u
INNER JOIN 
	ushouseholdincome_statistics us
ON 
	u.id = us.id
GROUP BY 
	u.State_Name, u.City
ORDER BY
	ROUND(AVG(Mean), 2) DESC;
```

