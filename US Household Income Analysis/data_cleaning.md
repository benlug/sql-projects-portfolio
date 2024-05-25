# US Household Income Data Analysis

## Exploration and Precleaning 

Count the total number of records in the ushouseholdincome table
```sql
SELECT COUNT(id)
FROM ushouseholdincome_raw;
```

Rename the column 'ï»¿id' to 'id' in the Statistics table
```sql
ALTER TABLE ushouseholdincome_statistics_raw RENAME COLUMN `ï»¿id` TO `id`;
```

Count the total number of records in the Statistics table
```sql
SELECT COUNT(id)
FROM ushouseholdincome_statistics_raw;
```

Identify duplicate ids
```sql
SELECT id, COUNT(id)
FROM ushouseholdincome_raw
GROUP BY id
HAVING COUNT(id) > 1;
```

 Identify duplicate ids in the Statistics table
```sql
SELECT id, COUNT(id)
FROM ushouseholdincome_statistics_raw
GROUP BY id
HAVING COUNT(id) > 1;
```

List distinct state names 
```sql
SELECT DISTINCT State_Name
FROM ushouseholdincome_raw
ORDER BY State_Name;
```

List distinct state abbreviations
```sql
SELECT DISTINCT State_ab
FROM ushouseholdincome_raw
ORDER BY State_ab;
```

Count the number of records for each type
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
