-- Data Cleanining Steps

-- Count the total number of records in the ushouseholdincome table
SELECT COUNT(id)
FROM ushouseholdincome_raw;

-- SELECT *
-- FROM ushouseholdincome_statistics_raw;
-- Rename the column 'ï»¿id' to 'id' in the ushouseholdincome_statistics table
ALTER TABLE ushouseholdincome_statistics_raw RENAME COLUMN `ï»¿id` TO `id`;

-- Count the total number of records in the ushouseholdincome_statistics table
SELECT COUNT(id)
FROM ushouseholdincome_statistics_raw;

-- Identify duplicate ids in the ushouseholdincome table
SELECT id, COUNT(id)
FROM ushouseholdincome_raw
GROUP BY id
HAVING COUNT(id) > 1;

-- Alternative method to identify duplicates, providing a row_id for deletion
-- SELECT row_id
-- FROM (
-- 	SELECT
-- 		row_id, 
-- 		id,
-- 		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
-- 	FROM
-- 		ushouseholdincome_raw) AS duplicates
-- WHERE 
-- 	row_num > 1;

-- Identify duplicate ids in the ushouseholdincome_statistics table
SELECT
	id, COUNT(id)
FROM
	ushouseholdincome_statistics_raw
GROUP BY
	id
HAVING
	COUNT(id) > 1;

-- List distinct state names in the ushouseholdincome table
SELECT DISTINCT
	State_Name
FROM 
	ushouseholdincome_raw
ORDER BY 
	State_Name;

-- List distinct state abbreviations in the ushouseholdincome table
SELECT DISTINCT
	State_ab
FROM 
	ushouseholdincome_raw
ORDER BY 
	State_ab;

-- Count the number of records for each type in the ushouseholdincome table
SELECT
	Type, COUNT(Type)
FROM 
	ushouseholdincome_raw
GROUP BY 
	Type;
    
-- Identify records with zero, empty, or null values for ALand and AWater
SELECT   
	ALand, AWater
FROM 	
	ushouseholdincome_raw
WHERE 
	AWater = 0 OR AWater = '' OR AWater IS NULL OR
	ALand = 0 OR ALand = '' OR ALand IS NULL;
