# World Life Expectancy

USE world_life_expectancy;

-- Select all records from the world_life_expectancy table
SELECT 
	*
FROM 
	world_life_expectancy;

-- Calculate the minimum and maximum life expectancy for each country,
-- and the increase in life expectancy over 15 years. Only include countries 
-- where the minimum life expectancy is not zero. Order by the increase in life expectancy.
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

-- Calculate the average life expectancy for each year. 
-- Only include years where life expectancy is not zero. Order by year.
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

-- Calculate the average life expectancy and GDP for each country.
-- Only include countries where both life expectancy and GDP are greater than zero.
-- Order by average GDP in descending order.
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

-- Count the number of countries with high GDP (>= 1500) and low GDP (< 1500),
-- and calculate the average life expectancy for each group.
SELECT
	SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
    AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_GDP_Life_Expectancy,
    SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
    AVG(CASE WHEN GDP < 1500 THEN `Life expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM 
	world_life_expectancy;

-- Calculate the average life expectancy for each status (Developed/Developing).
SELECT
	Status,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_exp
FROM 
	world_life_expectancy
GROUP BY
	Status;

-- Count the number of distinct countries and calculate the average life expectancy
-- for each status (Developed/Developing).
SELECT
	Status,
    COUNT(DISTINCT Country) AS country_count,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_exp
FROM 
	world_life_expectancy
GROUP BY
	Status;

-- Calculate the average life expectancy and BMI for each country.
-- Only include countries where both life expectancy and BMI are greater than zero.
-- Order by average BMI in ascending order.
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

-- Calculate the rolling total of adult mortality for Germany, United States, and United Kingdom.
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


































    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    