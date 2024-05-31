# Data Cleaning

This script performs a simple data cleaning of the 'world_life_expectancy' dataset by removing duplicates, imputing missing values, and updating the 'Status' variable using MySQL. Each query is accompanied by a short explanation of the query or the goal behind it.

Get an overview of all records in the world_life_expectancy table
```sql
SELECT * 
FROM world_life_expectancy;
```

Identify duplicates by country and year to understand the level of redundancy in the data.
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

Alternative method using a subquery to identify duplicates, providing a Row_ID for deletion.
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

Delete duplicates identified by the previous query.
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


Check for empty or null `Status` values.
```sql
SELECT *
FROM 
	world_life_expectancy
WHERE 
	Status = '' OR Status IS NULL;
```

List distinct non-empty `Status` values.
```sql
SELECT 
	DISTINCT Status
FROM 
	world_life_expectancy
WHERE 
	Status != '';
```

Set `Status` to 'Developing' for records where it is empty but other records of the same country have 'Developing'.
```sql
UPDATE world_life_expectancy world_1
INNER JOIN world_life_expectancy world_2
	ON world_1.Country = world_2.Country
SET world_1.Status = 'Developing'
WHERE world_1.Status = '' AND world_2.Status != '' AND world_2.Status = 'Developing';
```

Set `Status` to 'Developed' for records where it is empty but other records of the same country have 'Developed'.
```sql
UPDATE world_life_expectancy world_1
INNER JOIN world_life_expectancy world_2
	ON world_1.Country = world_2.Country
SET world_1.Status = 'Developed'
WHERE world_1.Status = '' AND world_2.Status != '' AND world_2.Status = 'Developed';
```

Calculate mean life expectancy for records with missing values using adjacent years.
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

Update life expectancy for records with missing values using the calculated mean.
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

# Exploratory Data Analysis

This script performs a simple EDA on the 'world_life_expectancy' dataset to understand various trends and statistics.

## Data Analysis

Select all records from the `world_life_expectancy` table.
```sql
SELECT *
FROM world_life_expectancy;
```

Calculate the minimum and maximum life expectancy for each country, and the increase in life expectancy over 15 years. Only include countries where the minimum life expectancy is not 0. 
```sql
SELECT
	Country, 
    MIN(`Life expectancy`) AS min_life_expec, 
    MAX(`Life expectancy`) AS max_life_expec,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 2) AS life_increase_15_years
FROM
	world_life_expectancy
GROUP BY 
	Country
HAVING
	MIN(`Life expectancy`) != 0
ORDER BY 
	life_increase_15_years DESC;
```

Calculate the average life expectancy for each year. Only include years where life expectancy is not 0. 
```sql
SELECT 
	Year, ROUND(AVG(`Life expectancy`), 2) AS avg_life_exp
FROM 
	world_life_expectancy
WHERE
	`Life expectancy` != 0
GROUP BY 
	Year  
ORDER BY
	Year;
```

Calculate the average life expectancy and GDP for each country. Only include countries where both life expectancy and GDP are greater than 0.
```sql
SELECT 
	Country, 
    ROUND(AVG(`Life expectancy`), 2) AS avg_life_exp, 
    ROUND(AVG(GDP), 2) AS avg_gdp
FROM
	world_life_expectancy
GROUP BY 
	Country
HAVING 
	avg_life_exp > 0 AND avg_gdp > 0
ORDER BY
	avg_gdp DESC;
```

Count the number of countries with high GDP (>= 1500) and low GDP (< 1500), and calculate the average life expectancy for each group.
```sql
SELECT
	SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
    AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_GDP_Life_Expectancy,
    SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
    AVG(CASE WHEN GDP < 1500 THEN `Life expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM 
	world_life_expectancy;
```

Calculate the average life expectancy for each `Status` (Developed/Developing).
```sql
SELECT
	Status,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_exp
FROM 
	world_life_expectancy
GROUP BY
	Status;
```

Count the number of distinct countries and calculate the average life expectancy for each `Status` (Developed/Developing).
```sql
SELECT
	Status,
    COUNT(DISTINCT Country) AS country_count,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_exp
FROM 
	world_life_expectancy
GROUP BY
	Status;
```

Calculate the average life expectancy and BMI for each country. Only include countries where both life expectancy and BMI are greater than zero. 
```sql
SELECT
	Country, 
    ROUND(AVG(`Life expectancy`), 2) AS avg_life_exp, 
    ROUND(AVG(BMI), 2) AS avg_bmi
FROM
	world_life_expectancy
GROUP BY 
	Country
HAVING 
	avg_life_exp > 0 AND avg_bmi > 0
ORDER BY
	avg_bmi ASC;
```

Calculate the rolling total of adult mortality for Germany, United States, and United Kingdom.
```sql
SELECT
    Country, 
    Year,
    `Life expectancy`, 
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM
    world_life_expectancy
WHERE
    Country IN ('Germany', 'United States', 'United Kingdom');
```






















































