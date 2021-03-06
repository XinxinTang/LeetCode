-----------------------------------------------------------------------
-- 	LeetCode 1127. User Purchase Platform
--
-- 	Hard
--
-- 	SQL Schema
--
--  Table: Spending
--
--  +-------------+---------+
--  | Column Name | Type    |
--  +-------------+---------+
--  | user_id     | int     |
--  | spend_date  | date    |
--  | platform    | enum    | 
--  | amount      | int     |
--  +-------------+---------+
--  The table logs the spendings history of users that make purchases from 
--  an online shopping website which has a desktop and a mobile application.
--  (user_id, spend_date, platform) is the primary key of this table.
--  The platform column is an ENUM type of ('desktop', 'mobile').
--  Write an SQL query to find the total number of users and the total amount 
--  spent using mobile only, desktop only and both mobile and desktop 
--  together for each date.
--
--  The query result format is in the following example:
-- 
--  Spending table:
--  +---------+------------+----------+--------+
--  | user_id | spend_date | platform | amount |
--  +---------+------------+----------+--------+
--  | 1       | 2019-07-01 | mobile   | 100    |
--  | 1       | 2019-07-01 | desktop  | 100    |
--  | 2       | 2019-07-01 | mobile   | 100    |
--  | 2       | 2019-07-02 | mobile   | 100    |
--  | 3       | 2019-07-01 | desktop  | 100    |
--  | 3       | 2019-07-02 | desktop  | 100    |
--  +---------+------------+----------+--------+
--
--  Result table:
--  +------------+----------+--------------+-------------+
--  | spend_date | platform | total_amount | total_users |
--  +------------+----------+--------------+-------------+
--  | 2019-07-01 | desktop  | 100          | 1           |
--  | 2019-07-01 | mobile   | 100          | 1           |
--  | 2019-07-01 | both     | 200          | 1           |
--  | 2019-07-02 | desktop  | 100          | 1           |
--  | 2019-07-02 | mobile   | 100          | 1           |
--  | 2019-07-02 | both     | 0            | 0           |
--  +------------+----------+--------------+-------------+ 
--  On 2019-07-01, user 1 purchased using both desktop and mobile, user 2 
--  purchased using mobile only and user 3 purchased using desktop only.
--  On 2019-07-02, user 2 purchased using mobile only, user 3 purchased using 
--  desktop only and no one purchased using both platforms.
--------------------------------------------------------------------
WITH Purchase_CTE (user_id, spend_date, mobile_amount, desktop_amount)  
AS  
(  
	SELECT
		CASE WHEN A.user_id IS NULL THEN B.user_id ELSE A.user_id END AS user_id,
		CASE WHEN A.spend_date IS NULL THEN B.spend_date ELSE A.spend_date END AS spend_date,
		A.amount AS mobile_amount,
		B.amount AS desktop_amount	
	FROM
	(
		SELECT
			user_id,
			spend_date,
			amount
		FROM Spending
		WHERE platform = 'mobile'
	) AS A
	FULL OUTER JOIN
	(
		SELECT
			user_id,
			spend_date,
			amount
		FROM Spending
		WHERE platform = 'desktop'
	) AS B
	ON 
		A.user_id = B.user_id AND 
		A.spend_date = B.spend_date 
)
SELECT
    spend_date,
	'desktop' AS platform,
	SUM(CASE WHEN mobile_amount IS NULL AND desktop_amount IS NOT NULL THEN desktop_amount ELSE 0 END) AS total_amount,
	SUM(CASE WHEN mobile_amount IS NULL AND desktop_amount IS NOT NULL THEN 1 ELSE 0 END) AS total_users
FROM 
	Purchase_CTE
GROUP BY 
    spend_date
UNION ALL
SELECT
    spend_date,
	'mobile' AS platform,
	SUM(CASE WHEN desktop_amount IS NULL AND mobile_amount IS NOT NULL THEN mobile_amount ELSE 0 END) AS total_amount,
	SUM(CASE WHEN desktop_amount IS NULL AND mobile_amount IS NOT NULL THEN 1 ELSE 0 END) AS total_users
FROM 
	Purchase_CTE
GROUP BY 
    spend_date
UNION ALL
SELECT
    spend_date,
	'both' AS platform,
	SUM(CASE WHEN mobile_amount IS NOT NULL AND desktop_amount IS NOT NULL 
	         THEN (mobile_amount + desktop_amount) 
			 ELSE 0 END) AS total_amount,
	SUM(CASE WHEN mobile_amount IS NOT NULL AND desktop_amount IS NOT NULL THEN 1 ELSE 0 END) AS total_users
FROM 
	Purchase_CTE	
GROUP BY 
    spend_date
;