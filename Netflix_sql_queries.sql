--Q1. Count the no. of movies and tv shows
select DISTINCT(COUNT(show_id)) as Total_count , type
from netflix
group by type;

--Q2. Find the most common ratings for movies and tv shows

;WITH counted AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS total_count
    FROM netflix
    GROUP BY type, rating
)
SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        total_count,
        RANK() OVER (PARTITION BY type ORDER BY total_count DESC) AS ranking
    FROM counted
) AS t1
WHERE ranking = 1;


-- Q3. List all the Movies which were released in 2020

select *
from netflix
where release_year = 2020 and type = 'Movie';

-- Q4. Identify the longest movie

select distinct(title)
from netflix
where type = 'Movie'
      AND  duration = (SELECT MAX(duration) from netflix) ;


 
-- Q5. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE date_added >= DATEADD(YEAR, -5, GETDATE());

--Q6. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT DISTINCT(title) as name, *
FROM netflix
where director = 'Rajiv Chilaka';

--Q7.List all TV shows with more than 5 seasons

SELECT DISTINCT(title) as tv_show_name , duration
from netflix
where type = 'TV Show'
      AND duration > '5 seasons' ;

-- Q8.Count the number of content items in each genre

WITH SplitGenres AS (
    SELECT 
        value AS genre
    FROM netflix
    CROSS APPLY STRING_SPLIT(listed_in, ',')
),
TrimmedGenres AS (
    SELECT LTRIM(RTRIM(genre)) AS genre
    FROM SplitGenres
)
SELECT 
    genre,
    COUNT(*) AS content_count
FROM TrimmedGenres
GROUP BY genre
ORDER BY content_count DESC;


--Q9.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!

WITH IndianContent AS (
    SELECT 
        release_year
    FROM netflix
    WHERE country LIKE '%India%' -- filters rows where India is mentioned
),
ContentPerYear AS (
    SELECT 
        release_year,
        COUNT(*) AS content_count
    FROM IndianContent
    GROUP BY release_year
),
AvgContentPerYear AS (
    SELECT 
        release_year,
        ROUND(AVG(content_count) OVER (), 2) AS avg_content,
        content_count
    FROM ContentPerYear
)
SELECT TOP 5 
    release_year,
    avg_content,
    content_count
FROM AvgContentPerYear
ORDER BY content_count DESC;

-- Q10. List all movies that are documentaries

SELECT DISTINCT(title) 
from netflix
where type = 'Movie'
      AND  listed_in like '%Documentaries%' ;

-- Q11. Find all content without a director

SELECT *
from netflix
where director is null;

-- Q12.  Find how many movies actor 'Salman Khan' appeared in last 10 years!

select show_id, title, cast, date_added
from netflix
where type = 'Movie'
      AND lower(cast) like '% salman khan%'
	  AND date_added >= DATEADD(YEAR, -10, GETDATE()) ;
      
-- Q13.  Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category. 

SELECT 
  CASE 
    WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
  END AS category,
  COUNT(*) AS total_items
FROM netflix
GROUP BY 
  CASE 
    WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
  END;




