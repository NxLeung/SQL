CREATE TABLE "departments" (
	"dept_no" varchar NOT NULL,
	"dept_name" varchar NOT NULL,
	CONSTRAINT "pk_departments" PRIMARY KEY ("dept_no")
);

CREATE TABLE "dept_emp" (
	"emp_no" int NOT NULL,
	"dept_no" varchar NOT NULL,
	"from_date" date NOT NULL,
	"to_date" date NOT NULL
);

CREATE TABLE "dept_manager" (
	"dept_no" varchar NOT NULL,
	"emp_no" int NOT NULL,
	"from_date" date NOT NULL,
	"to_date" date NOT NULL
);

CREATE TABLE "employees" (
	"emp_no" int NOT NULL,
	"birth_date" date NOT NULL,
	"first_name" varchar NOT NULL,
	"last_name" varchar NOT NULL,
	"gender" varchar(1) NOT NULL,
	"hire_date" date NOT NULL,
	CONSTRAINT "pk_employees" PRIMARY KEY ("emp_no")
);

CREATE TABLE "salaries" (
	"emp_no" int NOT NULL,
	"salary" int NOT NULL,
	"from_date" date NOT NULL,
	"to_date" date NOT NULL
);

CREATE TABLE "titles" (
	"emp_no" int NOT NULL,
	"title" varchar NOT NULL,
	"from_date" date NOT NULL,
	"to_date" date NOT NULL
);

ALTER TABLE "dept_emp"
	ADD CONSTRAINT "fk_dept_emp_emp_no" FOREIGN KEY ("emp_no") REFERENCES "employees" ("emp_no");

ALTER TABLE "dept_emp"
	ADD CONSTRAINT "fk_dept_emp_dept_no" FOREIGN KEY ("dept_no") REFERENCES "departments" ("dept_no");

-- Contraint for dates
ALTER TABLE "dept_emp"
	ADD CONSTRAINT "dept_emp_overlap_date_range"
	EXCLUDE USING gist (emp_no WITH =, daterange(from_date, to_date, '[]') WITH &&);

ALTER TABLE "dept_emp" DROP CONSTRAINT "dept_emp_overlap_date_range";

ALTER TABLE "dept_manager"
	ADD CONSTRAINT "fk_dept_manager_dept_no" FOREIGN KEY ("dept_no") REFERENCES "departments" ("dept_no");

ALTER TABLE "dept_manager"
	ADD CONSTRAINT "fk_dept_manager_emp_no" FOREIGN KEY ("emp_no") REFERENCES "employees" ("emp_no");

-- constraints for date and removal
ALTER TABLE "dept_manager"
	ADD CONSTRAINT "dept_manager_overlap_date_range"
	EXCLUDE USING gist (dept_no WITH =, daterange(from_date, to_date, '[]') WITH &&);

ALTER TABLE "dept_manager" DROP CONSTRAINT "dept_manager_overlap_date_range";

ALTER TABLE "salaries"
	ADD CONSTRAINT "fk_salaries_emp_no" FOREIGN KEY ("emp_no") REFERENCES "employees" ("emp_no");

-- constraints for date and removal
ALTER TABLE "salaries"
	ADD CONSTRAINT "salary_overlap_date_range"
	EXCLUDE USING gist (emp_no WITH =, daterange(from_date, to_date, '[]') WITH &&);

ALTER TABLE "salaries" DROP CONSTRAINT "salary_overlap_date_range";

ALTER TABLE "titles"
	ADD CONSTRAINT "fk_titles_emp_no" FOREIGN KEY ("emp_no") REFERENCES "employees" ("emp_no");

-- constraints for date and removal
CREATE EXTENSION btree_gist;

ALTER TABLE "titles"
	ADD CONSTRAINT "overlap_date_range"
	EXCLUDE USING gist (emp_no WITH =, daterange(from_date, to_date, '[]') WITH &&);

ALTER TABLE "titles" DROP CONSTRAINT "overlap_date_range";

DELETE FROM employees;

SELECT
	'title' AS TABLE,
	count(*)
FROM
	titles
	-- List the following details of each employee: employee number, last name, first name, gender, and salary.
	SELECT
		employees.emp_no,
		first_name,
		last_name,
		gender,
		salaries.salary
	FROM
		employees
		JOIN salaries ON employees.emp_no = salaries.emp_no;

-- List employees who were hired in 1986.
SELECT
	*
FROM
	employees
WHERE
	hire_date BETWEEN '1986-01-01'
	AND '1986-12-31';

-- List the manager of each department with the following information: department number, department name, the manager's employee number, last name, first name, and start and end employment dates.
SELECT
	departments.dept_no,
	dept_name,
	dept_manager.emp_no,
	employees.last_name,
	employees.first_name,
	dept_emp.from_date,
	dept_emp.to_date
FROM
	departments
	JOIN dept_manager ON departments.dept_no = dept_manager.dept_no
	JOIN employees ON dept_manager.emp_no = employees.emp_no
	JOIN dept_emp ON dept_manager.emp_no = dept_emp.emp_no
WHERE
	dept_manager.to_date = '9999-01-01'
ORDER BY
	dept_no ASC;

-- List the department of each employee with the following information: employee number, last name, first name, and department name.
SELECT
	employees.emp_no,
	first_name,
	last_name,
	dept_name
FROM
	employees
	JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
	JOIN departments ON dept_emp.dept_no = departments.dept_no;

-- List all employees whose first name is "Hercules" and last names begin with "B."
SELECT
	first_name,
	last_name
FROM
	employees
WHERE
	first_name = 'Hercules'
	AND last_name LIKE 'B%';

-- List all employees in the Sales department, including their employee number, last name, first name, and department name.
SELECT
	employees.emp_no,
	last_name,
	first_name,
	dept_name
FROM
	employees
	JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
	JOIN departments ON dept_emp.dept_no = departments.dept_no
WHERE
	dept_name = 'Sales';

-- List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.
SELECT
	employees.emp_no,
	last_name,
	first_name,
	dept_name
FROM
	employees
	JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
	JOIN departments ON dept_emp.dept_no = departments.dept_no
WHERE
	dept_name = 'Sales'
	OR dept_name = 'Development';

-- In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.
SELECT
	last_name,
	count(last_name) AS namecount
FROM
	employees
GROUP BY
	last_name
ORDER BY
	namecount DESC;