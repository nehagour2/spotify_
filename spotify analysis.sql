Create Database spotify;
use spotify;
select * from songs;

-- Artists with the Most Songs Released After 2020 

SELECT `artist(s)_name` AS Artist, COUNT(*) AS Song_Count
FROM Songs
WHERE released_year > 2020
GROUP BY `artist(s)_name`
HAVING Song_Count = (
    SELECT MAX(Song_Count)
    FROM (
        SELECT `artist(s)_name`, COUNT(*) AS Song_Count
        FROM Songs
        WHERE released_year > 2020
        GROUP BY `artist(s)_name`
    ) AS artist_subquery
);

-- Songs that Appear in All Playlists

SELECT track_name AS Song, `artist(s)_name` AS Artist
FROM Songs
WHERE in_spotify_playlists > 0
  AND in_apple_playlists > 0
  AND in_deezer_playlists > 0;

-- Top 5 Artists with the Highest Average Streams
SELECT `artist(s)_name` AS Artist, AVG(CAST(streams AS UNSIGNED)) AS Avg_Streams
FROM Songs
GROUP BY `artist(s)_name`
ORDER BY Avg_Streams DESC
LIMIT 5;

-- Songs with Above-Average Streams for Their Release Year
SELECT track_name AS Song, `artist(s)_name` AS Artist, released_year AS Year, streams
FROM Songs s
WHERE CAST(streams AS UNSIGNED) > (
    SELECT AVG(CAST(streams AS UNSIGNED))
    FROM Songs
    WHERE released_year = s.released_year
);




SELECT `key`, 
       CASE 
           WHEN mode = 1 THEN 'Major'
           WHEN mode = 0 THEN 'Minor'
           ELSE 'Unknown'
       END AS Mode_Type,
       COUNT(*) AS Song_Count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Songs), 2) AS Percentage
FROM Songs
GROUP BY `key`, mode
ORDER BY `key`, Mode_Type;

-- Songs from the Most Represented Month
SELECT track_name AS Song, `artist(s)_name` AS Artist, released_month
FROM Songs
WHERE released_month = (
    SELECT released_month
    FROM Songs
    GROUP BY released_month
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Songs Missing in One or More Chart Categories

SELECT track_name AS Song, `artist(S)_name` AS Artist
FROM Songs
WHERE in_spotify_charts = 0
   OR in_apple_charts = 0
   OR in_deezer_charts = 0
   OR in_shazam_charts IS NULL;

-- Artists with the Most Songs Released per Year

WITH ArtistYearCount AS (
    SELECT `artist(s)_name` AS Artist,
           released_year AS Year,
           COUNT(*) AS Song_Count
    FROM Songs
    GROUP BY `artist(s)_name`, released_year
),
MaxSongCountPerYear AS (
    SELECT Year,
           MAX(Song_Count) AS Max_Song_Count
    FROM ArtistYearCount
    GROUP BY Year
)
SELECT a.Year, 
       a.Artist, 
       a.Song_Count
FROM ArtistYearCount a
JOIN MaxSongCountPerYear m
ON a.Year = m.Year AND a.Song_Count = m.Max_Song_Count
ORDER BY a.Year ASC, a.Artist ASC;
