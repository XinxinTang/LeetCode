-----------------------------------------------------------------------
-- 	LeetCode 618. Students Report By Geography
--
-- 	Hard
--
-- 	SQL Schema
--
--  A U.S graduate school has students from Asia, Europe and America. The 
--  students' location information are stored in table student as below.
-- 
--  | name   | continent |
--  |--------|-----------|
--  | Jack   | America   |
--  | Pascal | Europe    |
--  | Xi     | Asia      |
--  | Jane   | America   |
-- 
--  Pivot the continent column in this table so that each name is sorted 
--  alphabetically and displayed underneath its corresponding continent. 
--  The output headers should be America, Asia and Europe respectively. 
--  It is guaranteed that the student number from America is no less than 
--  either Asia or Europe.
-- 
--  For the sample input, the output is:
--  | America | Asia | Europe |
--  |---------|------|--------|
--  | Jack    | Xi   | Pascal |
--  | Jane    |      |        |
--
--  Follow-up: If it is unknown which continent has the most students, can 
--  you write a query to generate the student report?
--------------------------------------------------------------------
 SELECT
     B.America,
     C.Asia,
     D.Europe
FROM
(
    SELECT
        DISTINCT
        row_id
    FROM
    (
        SELECT 
            name,
            continent,
	        ROW_NUMBER() OVER (PARTITION BY continent ORDER BY name) AS row_id
        FROM student            
    ) AS T
) AS A
LEFT OUTER JOIN
( 
    SELECT 
        name AS America,
        ROW_NUMBER() OVER (PARTITION BY continent ORDER BY name) AS row_id
    FROM student
    WHERE continent = 'America'
) AS B
ON A.row_id = B.row_id
LEFT OUTER JOIN
( 
    SELECT 
        name AS Asia,
	    ROW_NUMBER() OVER (PARTITION BY continent ORDER BY name) AS row_id
    FROM student
    WHERE continent = 'Asia'
) AS C
ON A.row_id = C.row_id
LEFT OUTER JOIN
( 
    SELECT 
        name AS Europe,
        ROW_NUMBER() OVER (PARTITION BY continent ORDER BY name) AS row_id
    FROM student
    WHERE continent = 'Europe'
) AS D
ON A.row_id = D.row_id
ORDER BY America
;