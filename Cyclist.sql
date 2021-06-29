USE Cyclist

--Merging All tables into One
WITH mergedcte
AS
(
SELECT * FROM April2020
UNION ALL
SELECT * FROM May2020
UNION ALL
SELECT * FROM June2020
UNION ALL
SELECT * FROM July2020
UNION ALL
SELECT * FROM August2020
UNION ALL
SELECT * FROM September2020
UNION ALL
SELECT * FROM October2020
UNION ALL
SELECT * FROM November2020
UNION ALL
SELECT * FROM December2020
UNION ALL
SELECT * FROM January2021
UNION ALL
SELECT * FROM February2021
UNION ALL
SELECT * FROM March2021
)
INSERT INTO cyclistmerged
SELECT * FROM mergedcte


--Adding ride_length and weekday columns
SELECT /*TOP 100*/
	rideable_type,
	started_at,
	ended_at,
	DATEDIFF(MINUTE, started_at, ended_at) AS ride_length,
	DATEPART(WEEKDAY, started_at) AS weekday,
	member_casual 
FROM 
	cyclistmerged

--Update active column
UPDATE cyclistmerged
SET
active = CASE 
			WHEN DATEDIFF(MINUTE, started_at, ended_at) >= 0 THEN 1
			WHEN DATEDIFF(MINUTE, started_at, ended_at) < 0 THEN 0
		 END

--Mean Ride length
SELECT
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS mean_ride_length
FROM
	cyclistmerged
WHERE
	active = 1

--Ride lengths greater then Average ride length (Inner query)
SELECT 
	rideable_type,
	started_at,
	ended_at,
	DATEDIFF(MINUTE, started_at, ended_at) AS ride_length,
	DATEPART(WEEKDAY, started_at) AS weekday,
	member_casual  FROM cyclistmerged
WHERE 
	DATEDIFF(MINUTE, started_at, ended_at) > 
	(SELECT
		AVG(DATEDIFF(MINUTE, started_at, ended_at))
	 FROM
		cyclistmerged
	 WHERE
		active = 1
	)

--Weekday with most rides (1 = Sunday and 7 = Saturday)
SELECT
	DATEPART(WEEKDAY, started_at) AS weekday,
	COUNT(*) AS no_rides
FROM 
	cyclistmerged
WHERE
	active = 1
GROUP BY
	DATEPART(WEEKDAY, started_at)
ORDER BY 
	no_rides DESC

--Average ride lengths for members and casual riders
SELECT
	member_casual,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM 
	cyclistmerged
WHERE
	active = 1
GROUP BY
	member_casual


--Average ride length by day of the week
SELECT
	DATEPART(WEEKDAY, started_at) AS weekday,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM 
	cyclistmerged
WHERE 
	active = 1
GROUP BY
	DATEPART(WEEKDAY, started_at)
ORDER BY
	avg_ride_length DESC


--Average ride length by month
SELECT
	DATEPART(MONTH, started_at) AS month,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM 
	cyclistmerged
WHERE 
	active = 1
GROUP BY
	DATEPART(MONTH, started_at)
ORDER BY
	avg_ride_length DESC

--No of rides per month
SELECT
	DATEPART(MONTH, started_at) AS month,
	COUNT(*) AS no_rides
FROM 
	cyclistmerged
WHERE 
	active = 1
GROUP BY
	DATEPART(MONTH, started_at)
ORDER BY
	no_rides DESC


--Average ride length and number of rides by month and member type
SELECT
	DATEPART(MONTH, started_at) AS month,
	member_casual,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length,
	COUNT(*) AS no_rides
FROM 
	cyclistmerged
WHERE 
	active = 1
GROUP BY
	DATEPART(MONTH, started_at),
	member_casual
ORDER BY
	avg_ride_length DESC


-- Percentage of rides per member type 
SELECT 
	member_casual,
	CAST(COUNT(*) AS float) AS no_rides,
	CAST(SUM(COUNT(*)) OVER () AS float) AS total_rides,
	(CAST(COUNT(*) AS float) / (CAST(SUM(COUNT(*)) OVER () AS float))) * 100 AS percent_ride
FROM
	cyclistmerged
WHERE
	active = 1
GROUP BY
	member_casual

--Bike type by member
SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS no_rides
FROM
	cyclistmerged
GROUP BY
	member_casual,
	rideable_type
ORDER BY
	no_rides