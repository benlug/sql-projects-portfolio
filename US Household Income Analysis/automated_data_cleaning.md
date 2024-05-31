## Exploration and Precleaning 

Count the total number of records in the ushouseholdincome table to get an onverview.
```sql
SELECT COUNT(id)
FROM ushouseholdincome_raw;
```

Rename the column 'ï»¿id' to 'id' in the Statistics table to correct any encoding issues and ensure consistency.
```sql
ALTER TABLE ushouseholdincome_statistics_raw RENAME COLUMN `ï»¿id` TO `id`;
```

Count the total number of records in the Statistics table.
```sql
SELECT COUNT(id)
FROM ushouseholdincome_statistics_raw;
```

Identify duplicate ids.
```sql
SELECT id, COUNT(id)
FROM ushouseholdincome_raw
GROUP BY id
HAVING COUNT(id) > 1;
```

 Identify duplicate ids in the Statistics table.
```sql
SELECT id, COUNT(id)
FROM ushouseholdincome_statistics_raw
GROUP BY id
HAVING COUNT(id) > 1;
```

List distinct state names.
```sql
SELECT DISTINCT State_Name
FROM ushouseholdincome_raw
ORDER BY State_Name;
```

List distinct state abbreviations.
```sql
SELECT DISTINCT State_ab
FROM ushouseholdincome_raw
ORDER BY State_ab;
```

Count the number of records for each type to understand the distribution of different types in the dataset.
```sql
SELECT Type, COUNT(Type)
FROM ushouseholdincome_raw
GROUP BY Type;
```

Identify records with zero, empty, or null values for ALand and AWater
```sql
SELECT ALand, AWater
FROM ushouseholdincome_raw
WHERE AWater = 0 OR AWater = '' OR AWater IS NULL OR
      ALand = 0 OR ALand = '' OR ALand IS NULL;
```

## Automated Data Cleaning 

This script cleans the 'ushouseholdincome' data by removing duplicates, correcting state names, and updating place names.

```sql
DELIMITER $$
-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;

-- Create the stored procedure to clean and copy data
CREATE PROCEDURE Copy_and_Clean_Data()
BEGIN 
    -- Create new table if it doesn't exist
    CREATE TABLE IF NOT EXISTS `ushouseholdincome_cleaned` (
        `row_id` int DEFAULT NULL,
        `id` int DEFAULT NULL,
        `State_Code` int DEFAULT NULL,
        `State_Name` text,
        `State_ab` text,
        `County` text,
        `City` text,
        `Place` text,
        `Type` text,
        `Primary` text,
        `Zip_Code` int DEFAULT NULL,
        `Area_Code` int DEFAULT NULL,
        `ALand` int DEFAULT NULL,
        `AWater` int DEFAULT NULL,
        `Lat` double DEFAULT NULL,
        `Lon` double DEFAULT NULL,
        `TimeStamp` timestamp DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

    -- Copy data to new table
    INSERT INTO ushouseholdincome_cleaned
    SELECT *, CURRENT_TIMESTAMP
    FROM ushouseholdincome_raw;

    -- Data Cleaning Steps	
    -- Delete duplicates identified by the previous query
    DELETE FROM ushouseholdincome_cleaned
    WHERE row_id IN (
        SELECT row_id
        FROM (
            SELECT
                row_id, 
                id,
                ROW_NUMBER() OVER(PARTITION BY id, `TimeStamp` ORDER BY id, `TimeStamp`) AS row_num
            FROM
                ushouseholdincome_cleaned) AS duplicates
        WHERE 
            row_num > 1
    );

    -- Correct misspelled state names
    UPDATE ushouseholdincome_cleaned
    SET State_Name = 'Georgia'
    WHERE State_Name = 'georia';

    UPDATE ushouseholdincome_cleaned
    SET State_Name = 'Alabama'
    WHERE State_Name = 'alabama';

    -- Update place names based on county and city information
    UPDATE ushouseholdincome_cleaned
    SET Place = 'Autaugaville' 
    WHERE County = 'Autauga County' AND City = 'Vinemont';

    -- Correct the 'Type' value
    UPDATE ushouseholdincome_cleaned
    SET Type = 'Borough' 
    WHERE Type = 'Boroughs';

    UPDATE ushouseholdincome_cleaned
    SET `Type` = 'CDP'
    WHERE `Type` = 'CPD';

    -- Convert County, City, and Place names to uppercase
    UPDATE ushouseholdincome_cleaned
    SET County = UPPER(County);

    UPDATE ushouseholdincome_cleaned
    SET City = UPPER(City);

    UPDATE ushouseholdincome_cleaned
    SET Place = UPPER(Place);

END $$
DELIMITER ;
```

```sql
CALL Copy_and_Clean_Data();

-- Check if stored procedure works
-- The following queries can be used to verify the results:
-- SELECT row_id, id, row_num
-- FROM (
-- 	SELECT
-- 		row_id, 
-- 		id,
-- 		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
-- 	FROM
-- 		ushouseholdincome_cleaned) AS duplicates
-- WHERE 
-- 	row_num > 1;
--     
-- SELECT COUNT(row_id)
-- FROM ushouseholdincome_cleaned;

-- SELECT State_Name, COUNT(State_Name)
-- FROM ushouseholdincome_cleaned
-- GROUP BY State_Name;

-- Create an event to run the data cleaning procedure every 30 days
DROP EVENT IF EXISTS run_data_cleaning;
CREATE EVENT run_data_cleaning
    ON SCHEDULE EVERY 30 DAY 
    DO CALL Copy_and_Clean_Data();
```

## Exploratory Data Analysis

```sql
USE us_household_income;
```

```sql
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

Calculate the total land area for the top 10 states.
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

Calculate the average mean and median household income for each state.
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

Calculate the average mean and median household income for each type.
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

Calculate the average mean and median household income for each city.
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

