-- This script cleans the 'ushouseholdincome' data by removing duplicates,
-- correcting state names, and updating place names.
    
DELIMITER $$
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;
CREATE PROCEDURE Copy_and_Clean_Data()
-- Create new table 
	BEGIN 
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
    
	-- Data Cleanining Steps	
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
    
    UPDATE ushouseholdincome_cleaned
	SET County = UPPER(County);
	
	UPDATE ushouseholdincome_cleaned
	SET City = UPPER(City);

	UPDATE ushouseholdincome_cleaned
	SET Place = UPPER(Place);

END $$
DELIMITER ;

CALL Copy_and_Clean_Data();

-- Check if stored procedure works
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


-- Create Event
DROP EVENT run_data_cleaning;
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 30 DAY 
    DO CALL Copy_and_Clean_Data();







