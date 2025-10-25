CREATE DATABASE IF NOT EXISTS employee;

DROP DATABASE IF EXISTS employee;

DROP TABLE IF EXISTS project_table;

DROP TABLE IF EXISTS emp_record_table;

DROP TABLE IF EXISTS data_science_team;

USE employee;

CREATE TABLE project_table (
	project_id VARCHAR(255) PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) NOT NULL,
    start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closure_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dev_qtr ENUM("Q1", "Q2", "Q3", "Q4") NOT NULL,
    status VARCHAR(255) NOT NULL,
    CONSTRAINT project_table_project_name_unique UNIQUE(project_name)
);

CREATE TABLE emp_record_table (
	emp_id VARCHAR(255) PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    role VARCHAR(255) NOT NULL,
    dept VARCHAR(255) NOT NULL,
    exp INT NOT NULL,
    country VARCHAR(255) NOT NULL,
    continent VARCHAR(255) NOT NULL,
    salary INT NOT NULL,
    emp_rating INT NOT NULL,
    manager_id VARCHAR(255),
    project_id VARCHAR(255),
    CONSTRAINT emp_record_table_exp_check CHECK(exp >= 0),
    CONSTRAINT emp_record_table_salary_check CHECK(salary > 2500),
    CONSTRAINT emp_record_table_emp_rating_check CHECK(emp_rating BETWEEN 1 AND 5),
    CONSTRAINT emp_record_table_project_id_fk FOREIGN KEY(project_id) REFERENCES project_table(project_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT emp_record_table_manager_id_fk FOREIGN KEY(manager_id) REFERENCES emp_record_table(emp_id)
);

CREATE TABLE data_science_team (
	emp_id VARCHAR(255) PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    role VARCHAR(255) NOT NULL,
    dept VARCHAR(255) NOT NULL,
    exp INT NOT NULL,
    country VARCHAR(255) NOT NULL,
    continent VARCHAR(255) NOT NULL,
    CONSTRAINT data_science_team_exp_check CHECK(exp >= 0)
);

-- Q3
SELECT	
	emp_id,
	first_name,
	last_name,
	gender,
	dept AS department
FROM 
	emp_record_table;

-- Q4
SELECT
	emp_id,
	first_name,
    last_name,
    gender,
    dept AS department,
    emp_rating AS rating
FROM 
	emp_record_table
WHERE 
	emp_rating < 2 
	OR emp_rating > 4 
	OR emp_rating BETWEEN 2 AND 4;
    
-- Q5
SELECT 
	CONCAT_WS(' ', first_name, last_name) full_name
FROM 
	emp_record_table
WHERE 
	dept = 'FINANCE';

-- Q6
SELECT 
	e.emp_id,
	e.first_name,
    e.last_name,
    e.role,
	COUNT(m.emp_id) number_of_reporters
FROM 
	emp_record_table e
INNER JOIN 
	emp_record_table m
ON 
	e.emp_id = m.manager_id
GROUP BY 
	e.emp_id;

-- Q7
SELECT
	*
FROM
	emp_record_table
WHERE 
	dept = 'healthcare'
 
UNION

SELECT
	*
FROM
	emp_record_table
WHERE 
	dept = 'finance';
    
-- Q8
SELECT 
	emp_id,
    first_name,
    last_name,
    role,
    dept,
    emp_rating,
    max(emp_rating) OVER(PARTITION BY dept) AS dept_wise_max_rating
FROM 
	emp_record_table
ORDER BY
	dept, emp_rating;

-- Q9
-- SELECT 
-- 	role,
--     max(salary) OVER w role_wise_max_salary,
--     min(salary) OVER w rolw_wise_min_salary
-- FROM 
-- 	emp_record_table
-- WINDOW w AS (
-- 	PARTITION BY role
-- );

SELECT 
	role,
    max(salary) role_wise_max_salary,
    min(salary) rolw_wise_min_salary
FROM 
	emp_record_table
GROUP BY
	role;
    
-- Q10
SELECT 
	emp_id,
    first_name,
    last_name,
    role,
    exp,
    RANK() OVER(ORDER BY exp DESC) rank_as_per_exp
FROM 
	emp_record_table;
    
-- Q11
CREATE VIEW employees_salary_gt_6000 AS
SELECT 
	emp_id,
    first_name,
    last_name,
    role,
    country,
    salary
FROM 
	emp_record_table
WHERE
	salary > 6000;
  
SELECT * FROM employees_salary_gt_6000;

-- Q12
SELECT
	emp_id,
    first_name,
    last_name,
	exp
FROM
	emp_record_table
WHERE 
	exp > (SELECT 10);

-- Q13
DELIMITER $$
CREATE PROCEDURE get_employees_with_exp_mt_3()
BEGIN
SELECT
	emp_id,
    first_name,
    last_name,
	exp
FROM
	emp_record_table
WHERE 
	exp > 3;
END $$
DELIMITER ;

call get_employees_with_exp_mt_3();

-- Q14
DELIMITER $$
CREATE FUNCTION check_job_profile_standard(exp INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
	DECLARE profile VARCHAR(255);
    IF exp <= 2 THEN
		SET profile = 'JUNIOR DATA SCIENTIST';
	ELSEIF exp > 2 AND exp <= 5 THEN
		SET profile = 'ASSOCIATE DATA SCIENTIST';
	ELSEIF exp > 5 AND exp <= 10 THEN
		SET profile = 'SENIOR DATA SCIENTIST';
	ELSEIF exp > 10 AND exp <= 12 THEN
		SET profile = 'LEAD DATA SCIENTIST';
	ELSEIF exp > 12 AND exp <= 16 THEN
		SET profile = 'MANAGER';
	ELSE 
		SET profile = 'UNKNOWN ROLE';
    END IF;
	RETURN profile;
END $$
DELIMITER ;

SELECT 
	emp_id,
    first_name,
    last_name,
    exp,
    role assigned_role,
    check_job_profile_standard(exp) role_as_per_standard
FROM 
	data_science_team
WHERE 
	role != check_job_profile_standard(exp);
    
    
-- Q15
-- Lookup data without indexing on first_name
EXPLAIN ANALYZE SELECT 
	emp_id,
    first_name,
    last_name,
    role,
    dept,
    country,
    salary
FROM 
	emp_record_table
WHERE 
	first_name = 'eric';

CREATE INDEX idx_first_name ON emp_record_table(first_name);

-- Lookup data with indexing on first_name
EXPLAIN ANALYZE SELECT 
	emp_id,
    first_name,
    last_name,
    role,
    dept,
    country,
    salary
FROM 
	emp_record_table
WHERE 
	first_name = 'eric';

-- Q16
SELECT 
	emp_id,
    first_name,
    last_name,
    exp,
    salary,
    round(((5/100) * salary) * emp_rating) AS bonus
FROM 
	emp_record_table;
    
-- Q17
SELECT 
	continent,
    country,
    ROUND(AVG(salary)) avg_salary_distribution
FROM 
	emp_record_table
GROUP BY
	continent, country
ORDER BY
	continent, country;