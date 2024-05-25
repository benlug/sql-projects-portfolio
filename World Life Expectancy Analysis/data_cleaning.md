# World Life Expectancy Data Cleaning

This script cleans the 'world_life_expectancy' data by removing duplicates, imputing missing values, and updating the 'Status'.

## Data Cleaning

Get an overview of all records in the world_life_expectancy table
```sql
SELECT 
	* 
FROM 
	world_life_expectancy;
```

Identify duplicates by country and year to understand the extent of redundancy in the data

```sql
SELECT 
	Country, Year,
	COUNT(*) AS country_year_count
FROM 
	world_life_expectancy
GROUP BY 
	Country, Year
HAVING 
	COUNT(*) >= 2;
```

Alternative method to identify duplicates, providing a Row_ID for deletion

```sql
SELECT *
FROM 
	(SELECT 
		Row_ID,
		CONCAT(Country, ' ', Year) AS country_year,
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, ' ', Year) ORDER BY CONCAT(Country, Year)) AS row_num
	FROM 
		world_life_expectancy) AS row_table
WHERE
	row_num > 1;
```

Delete duplicates identified by the previous query
```sql
DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
	SELECT Row_ID
	FROM 
		(SELECT 
			Row_ID,
			CONCAT(Country, ' ', Year) AS country_year,
			ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, ' ', Year) ORDER BY CONCAT(Country, Year)) AS row_num
		FROM 
			world_life_expectancy) AS row_table
	WHERE
		row_num > 1
	);
```


Check for empty or null Status values

```sql
SELECT *
FROM 
	world_life_expectancy
WHERE 
	Status = '' OR Status IS NULL;
```

List distinct non-empty Status values
```sql
SELECT 
	DISTINCT Status
FROM 
	world_life_expectancy
WHERE 
	Status != '';
```

Set Status to 'Developing' for records where it is empty but other records of the same country have 'Developing'
```sql
UPDATE world_life_expectancy world_1
INNER JOIN world_life_expectancy world_2
	ON world_1.Country = world_2.Country
SET world_1.Status = 'Developing'
WHERE world_1.Status = '' AND world_2.Status != '' AND world_2.Status = 'Developing';
```

Set Status to 'Developed' for records where it is empty but other records of the same country have 'Developed'

```sql
UPDATE world_life_expectancy world_1
INNER JOIN world_life_expectancy world_2
	ON world_1.Country = world_2.Country
SET world_1.Status = 'Developed'
WHERE world_1.Status = '' AND world_2.Status != '' AND world_2.Status = 'Developed';
```

Calculate mean life expectancy for records with missing values using adjacent years
```sql
SELECT 
	w1.Country, w1.Year, w1.`Life expectancy`,
    w2.Country, w2.Year, w2.`Life expectancy`,
    w3.Country, w3.Year, w3.`Life expectancy`,
    ROUND((w2.`Life expectancy` + w3.`Life expectancy`) / 2, 1) AS mean_imputed
FROM 
	world_life_expectancy w1
INNER JOIN 
	world_life_expectancy w2
ON 
	w1.Country = w2.Country AND w1.Year = (w2.Year - 1)
INNER JOIN 
	world_life_expectancy w3
ON 
	w1.Country = w3.Country AND w1.Year = (w3.Year + 1)
WHERE 
	w1.`Life expectancy` = '';
```

Update life expectancy for records with missing values using the calculated mean
```sql
UPDATE world_life_expectancy w1
INNER JOIN 
	world_life_expectancy w2
ON 
	w1.Country = w2.Country AND w1.Year = (w2.Year - 1)
INNER JOIN 
	world_life_expectancy w3
ON 
	w1.Country = w3.Country AND w1.Year = (w3.Year + 1)
SET w1.`Life expectancy` = ROUND((w2.`Life expectancy` + w3.`Life expectancy`) / 2, 1)
WHERE w1.`Life expectancy` = '';
```
























