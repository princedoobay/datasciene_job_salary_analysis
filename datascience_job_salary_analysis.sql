##1. **Experience and Salary Analysis**:
/* What is the average salary in USD for each experience level? */
SELECT avg(salary_in_usd) as average_salary, experience_level
FROM salaries
GROUP BY experience_level;

/* How does experience level impact salaries across different job titles? */
SELECT experience_level, job_title, avg(salary_in_usd) as average_salary
FROM salaries
GROUP BY job_title, experience_level
ORDER BY job_title, experience_level;

## 2. **Remote Work Analysis**
/* What is the average salary for remote, hybrid, and on-site positions? */
SELECT remote_ratio, avg(salary_in_usd) as average_salary
FROM salaries
GROUP BY remote_ratio;

/* Is there a difference in salary based on remote ratio within the same job titles? */
SELECT job_title, remote_ratio, avg(salary_in_usd) as average_salary
FROM salaries
GROUP BY job_title, remote_ratio
ORDER BY job_title, remote_ratio;

## 3. **Location-Based Analysis**:
/* Which country has the highest average salary in USD? */
SELECT company_location, avg(salary_in_usd) as average_salary
FROM salaries
GROUP BY company_location;

/* How does employee residence affect salaries compared to company location? */
SELECT company_location, employee_residence, avg(salary_in_usd) as average_salary
FROM salaries
GROUP BY employee_residence, company_location
ORDER BY average_salary DESC;

## 4. **Company Size Analysis**:
/* Does company size (Small, Medium, Large) have a significant impact on salary? */
SELECT company_size, AVG(salary_in_usd) as average_salary
FROM salaries
GROUP BY company_size;

/* What is the distribution of company sizes across different experience levels? */
SELECT experience_level, company_size, COUNT(*) as cnt
FROM salaries
GROUP BY experience_level, company_size
ORDER BY experience_level, company_size;

## 5. **Employment Type and Salary**:
/* What is the average salary for different employment types? */
SELECT employment_type, AVG(salary_in_usd) as average_salary
FROM salaries
GROUP BY employment_type;

/* Are full-time positions compensated significantly higher than part-time or contract roles? */
SELECT employment_type, AVG(salary_in_usd) as average_salary
FROM salaries
GROUP BY employment_type
ORDER BY average_salary;

## 6. **Job Title Analysis**:
/* Which job titles offer the highest and lowest salaries in USD? */
SELECT job_title, AVG(salary_in_usd) as average_salary
FROM salaries
GROUP BY job_title
ORDER BY average_salary DESC;

/* Are there job titles that have significant salary differences across different countries? */
SELECT job_title, employee_residence, AVG(salary_in_usd) as average_salary
FROM salaries
GROUP BY job_title, employee_residence
ORDER BY job_title, average_salary DESC;

## ----------- Medium Level Questions ----------------------
/*1.You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, 
for the title 'managers’ Paying salaries Exceeding $90,000 USD. */
SELECT DISTINCT company_location
FROM salaries
WHERE job_title LIKE '%manager%' AND salary_in_usd > 90000 AND remote_ratio = 100;

/*2.AS a remote work advocate Working for a progressive HR tech startup who place their fresher clients in large tech firms. you're tasked WITH 
Identifying top 5 Country Having  greatest count of large(company size) number of companies.*/
SELECT company_location, COUNT(company_size) as cnt FROM 
(
SELECT * FROM salaries WHERE company_size = 'L' AND experience_level = 'EN') As t
GROUP BY company_location
ORDER BY cnt DESC
LIMIT 5;

/*3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions in today's job market.*/
SET @count  = (SELECT count(*) FROM salaries WHERE remote_ratio = 100 AND salary_in_usd > 100000);
SET @total = (SELECT count(*) FROM salaries WHERE salary_in_usd > 100000);
SET @percentage = round((SELECT (@count)/ (@total))*100,2); 
SELECT @percentage as 'percentage_of_remote_roles_with_salries>100000';

/*4. Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average 
salaries exceed the average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.*/
SELECT t.job_title, t.company_location, t.avg_salary_EN, u.avg_salary FROM
(SELECT job_title, company_location, ROUND(AVG(salary_in_usd),2) as avg_salary_EN FROM salaries WHERE experience_level = 'EN'
GROUP BY job_title, company_location) as t
INNER JOIN 
(SELECT job_title, company_location, ROUND(AVG(salary_in_usd),2) as avg_salary FROM salaries
GROUP BY job_title, company_location) as u
ON t.job_title = u.job_title
WHERE avg_salary_EN > avg_salary;

/*5. You've been hired by a big HR Consultancy to look at how much people get paid in different Countries. Your job is to Find out for each job title
 which Country pays the maximum average salary. This helps you to place your candidates in those countries.*/
SELECT job_title, company_location, avg_salary, rnk FROM 
(SELECT *, DENSE_RANK() OVER (PARTITION BY t.job_title ORDER BY avg_salary DESC) as 'rnk' FROM 
(SELECT job_title, company_location, ROUND(AVG(salary_in_usd),2) as avg_salary FROM salaries
GROUP BY job_title, company_location) as t) as u
WHERE rnk = 1;

/*6. AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations where the average salary has consistently increased over the past few years (countries where data is available for 3 years Only(this and past two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/
use prince
WITH t AS
(
 SELECT * FROM  salaries WHERE company_location IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_location, AVG(salary_in_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY company_location HAVING num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_location,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_location, work_year, AVG(salary_IN_usd) AS average FROM t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022 -- step 3 and having step 4.

         --------------------------------------
select company_location, work_year, AVG(salary_in_usd) AS AVG_salary FROM salaries group by company_location, work_year;-- step 1
select company_location, work_year, AVG(salary_in_usd) AS AVG_salary FROM salaries where work_year>=year(current_date())-2 group by company_location, work_year  -- step 2
SELECT company_location, AVG(salary_in_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY company_location HAVING num_years = 3       -- STEP 3
 
 /* 7.	Picture yourself as a workforce strategist employed by a global HR tech startup. Your mission is to determine the percentage of fully remote work for each 
 experience level in 2021 and compare it with the corresponding figures for 2024, highlighting any significant increases or decreases in remote work adoption
 over the years.*/
WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level
 
/* 8. AS a compensatiON specialist at a Fortune 500 company, you're tasked with analyzing salary trends over time. Your objective is to calculate the average 
salary increase percentage for each experience level and job title between the years 2023 and 2024, helping the company stay competitive in the talent market.*/

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  -- step 1

SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL -- STEP 3

 
/* 9. You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement a security measure where employees
 in different experience level (e.g.Entry Level, Senior level etc.) can only access details relevant to their respective experience_level, ensuring data 
 confidentiality and minimizing the risk of unauthorized access.*/
 select * from salaries
 select distinct experience_level from salaries
 Show privileges
 
CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive-level '@'%' IDENTIFIED BY 'EX ';


CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN'

GRANT SELECT ON prince.entry_level TO 'Entry_level'@'%'

UPDATE view entry_level set WORK_YEAR = 2025 WHERE EMPLOYNMENT_TYPE='FT'

select * from entry_level
/* 10.	You are working with an consultancy firm, your client comes to you with certain data and preferences such as 
( their year of experience , their employment type, company location and company size )  and want to make an transaction into different domain in data industry
(like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering etc.)
your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update thier knowledge as  per the suggestion/.. 
The Suggestion should be based on average salary.*/

DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2))
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type 
    GROUP BY experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
END//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.

call GetAverageSalary('EN','FT','AU','M')

