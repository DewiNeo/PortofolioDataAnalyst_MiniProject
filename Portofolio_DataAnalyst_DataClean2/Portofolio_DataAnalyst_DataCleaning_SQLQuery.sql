USE Portofolio_DataAnalyst_DataCleaning

SELECT * FROM  NetflixDataset

-- CLEAN THE DUPLICATE DATA 
SELECT show_id, title, [counter] = COUNT(show_id)
FROM NetflixDataset
GROUP BY show_id, title
HAVING COUNT(show_id) > 1 --have duplicate data
ORDER BY show_id

SELECT Distinct show_id
from NetflixDataset

WITH CTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
		PARTITION BY show_id
					 ORDER BY show_id 
		) rowCounter
FROM netflixDataset
)
--SELECT * FROM CTE
--WHERE rowCounter > 1
DELETE FROM CTE
WHERE rowCounter > 1



-- FIXING date_added BECOME MORE EASY TO READ
SELECT date_added, 
	[date_added_Convert] = CAST(date_added AS DATE)
FROM NetflixDataset

ALTER TABLE NetflixDataset
ADD date_added_Convert DATE;

UPDATE NetflixDataset
SET date_added_Convert = CAST(date_added AS DATE)

SELECT * FROM NetflixDataset


--TIDY UP Duration FIELDS
SELECT duration,
CASE
	WHEN duration LIKE '%min' THEN '1 Season'
	ELSE
		duration
END AS season
FROM NetflixDataset

ALTER TABLE NetflixDataset
ADD season VARCHAR(255)

UPDATE NetflixDataset
SET season = 
	CASE
		WHEN duration LIKE '%min' THEN '1 Season'
		ELSE
			duration
	END

SELECT * FROM NetflixDataset

-- DELETE FULL OF NULL DATA
SELECT * 
FROM NetflixDataset
WHERE show_id IS NULL

DELETE FROM NetflixDataset
WHERE show_id IS NULL

-- DELETE DUPLICATE COLUMN
ALTER TABLE NetflixDataset
DROP COLUMN date_added
