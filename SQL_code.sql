-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(7),
	cinema_type	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(210),	
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT
	COUNT(*) as total_count
FROM netflix;

-- 15 Business Problems:

-- 1. Count the number of movies vs TV shows

SELECT cinema_type, COUNT(*) as total_content
FROM netflix
GROUP BY cinema_type;

-- 2. Find the most common rating for movies and TV shows

SELECT cinema_type, rating
FROM
(
SELECT 
	cinema_type,
	rating, 
	COUNT (*) as total,
	RANK() OVER(PARTITION BY cinema_type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1, 2
) as t1
WHERE ranking = 1


-- 3. List all movies released in a specific year (e.g. 2020)

SELECT *
FROM netflix
WHERE cinema_type = 'Movie' AND release_year = 2020


--4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ', ')) as distinct_country,
	COUNT(*) as total
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie

SELECT title, duration
FROM netflix
WHERE cinema_type = 'Movie' AND duration notnull
ORDER BY duration DESC

--6. Find content added in the last 5 years

SELECT * FROM netflix
WHERE TO_DATE(date_added, 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS'


-- 7. Find all the movies/ TV shows by director 'Rajiv Chilaka'

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons

SELECT *,
	SPLIT_PART(duration, ' ', 1) as season_num
FROM netflix
WHERE 
	cinema_type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5


-- 9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ', ')) as genre,
	COUNT(*) as total
FROM netflix
GROUP BY 1
ORDER BY 2 DESC


-- 10. Find each year and the average numbers of content release by India on Netflix
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	, 2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1


-- 11. List all the movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries'


-- 12. Find all content without a director

SELECT * 
FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Amir Khan' appeared in the last 15 years

SELECT *
FROM netflix
WHERE casts ILIKE '%Amir Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10


-- 15. Categorize content based on the presence of 'kill' and 'violence' keywords
-- 		Obj: Categorize as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise.
-- 		Count the number of items in each category.

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category

-----
