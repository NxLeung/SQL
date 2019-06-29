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

-- Contraint for dates and removal
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