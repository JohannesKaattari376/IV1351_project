-- =========================================
-- IV1351 Project – Logical/Physical Model
-- CREATE TABLE script for PostgreSQL
-- =========================================

-- (valfritt) ta bort tabeller om du kör om scriptet
-- DROP TABLE IF EXISTS teaching_allocation, planned_activity,
--     teaching_activity_type, course_instance, course,
--     period, employee, job_title, department CASCADE;

-- ==============
-- DEPARTMENT / JOB_TITLE / EMPLOYEE
-- ==============

CREATE TABLE department (
    department_id      SERIAL PRIMARY KEY,
    department_name    VARCHAR(100) NOT NULL UNIQUE,
    manager_id         INTEGER          -- FK -> employee, läggs på efteråt
);

CREATE TABLE job_title (
    job_title_id       SERIAL PRIMARY KEY,
    title              VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employee (
    employee_id        SERIAL PRIMARY KEY,
    employment_id      VARCHAR(20)  NOT NULL UNIQUE,
    first_name         VARCHAR(50)  NOT NULL,
    last_name          VARCHAR(50)  NOT NULL,
    email              VARCHAR(100) NOT NULL UNIQUE,
    phone_number       VARCHAR(20),
    salary             NUMERIC(10,2),
    department_id      INTEGER      NOT NULL,
    job_title_id       INTEGER,
    manager_id         INTEGER,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES department(department_id),
    CONSTRAINT fk_employee_job_title
        FOREIGN KEY (job_title_id) REFERENCES job_title(job_title_id),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);

-- nu när employee finns kan vi koppla department.manager_id
ALTER TABLE department
    ADD CONSTRAINT fk_department_manager
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id);

-- ==============
-- PERIOD
-- ==============

CREATE TABLE period (
    period_code   VARCHAR(2) PRIMARY KEY,   -- 'P1', 'P2', 'P3', 'P4'
    description   VARCHAR(50) NOT NULL
);

-- ==============
-- COURSE & COURSE_INSTANCE
-- ==============

CREATE TABLE course (
    course_code   VARCHAR(10) PRIMARY KEY,
    course_name   VARCHAR(100) NOT NULL,
    hp            NUMERIC(3,1) NOT NULL,
    min_students  INTEGER      NOT NULL,
    max_students  INTEGER      NOT NULL,
    department_id INTEGER      NOT NULL,
    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id) REFERENCES department(department_id),
    CONSTRAINT chk_course_students
        CHECK (min_students > 0 AND max_students >= min_students)
);

CREATE TABLE course_instance (
    course_instance_id VARCHAR(20) PRIMARY KEY,
    year               INTEGER      NOT NULL,
    num_students       INTEGER      NOT NULL,
    hp                 NUMERIC(3,1) NOT NULL,   -- snapshot av kursens hp
    course_code        VARCHAR(10)  NOT NULL,
    period_code        VARCHAR(2)   NOT NULL,
    CONSTRAINT fk_ci_course
        FOREIGN KEY (course_code) REFERENCES course(course_code),
    CONSTRAINT fk_ci_period
        FOREIGN KEY (period_code) REFERENCES period(period_code),
    CONSTRAINT chk_ci_students
        CHECK (num_students >= 0)
);

-- ==============
-- TEACHING_ACTIVITY_TYPE
-- ==============

CREATE TABLE teaching_activity_type (
    activity_type_id   SERIAL PRIMARY KEY,
    activity_name      VARCHAR(50) NOT NULL UNIQUE,
    factor             NUMERIC(5,2)      -- NULL om ingen faktor
);

-- ==============
-- PLANNED_ACTIVITY (komposit-PK)
-- ==============

CREATE TABLE planned_activity (
    course_instance_id VARCHAR(20) NOT NULL,
    activity_type_id   INTEGER     NOT NULL,
    planned_hours      NUMERIC(6,2) NOT NULL,
    CONSTRAINT pk_planned_activity
        PRIMARY KEY (course_instance_id, activity_type_id),
    CONSTRAINT fk_pa_ci
        FOREIGN KEY (course_instance_id)
        REFERENCES course_instance(course_instance_id),
    CONSTRAINT fk_pa_activity
        FOREIGN KEY (activity_type_id)
        REFERENCES teaching_activity_type(activity_type_id),
    CONSTRAINT chk_pa_hours
        CHECK (planned_hours >= 0)
);

-- ==============
-- TEACHING_ALLOCATION
-- ==============

CREATE TABLE teaching_allocation (
    allocation_id      SERIAL PRIMARY KEY,
    allocated_hours    NUMERIC(6,2) NOT NULL,
    employee_id        INTEGER      NOT NULL,
    course_instance_id VARCHAR(20)  NOT NULL,
    activity_type_id   INTEGER      NOT NULL,
    CONSTRAINT fk_ta_employee
        FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_ta_ci
        FOREIGN KEY (course_instance_id) REFERENCES course_instance(course_instance_id),
    CONSTRAINT fk_ta_activity
        FOREIGN KEY (activity_type_id) REFERENCES teaching_activity_type(activity_type_id),
    CONSTRAINT chk_ta_hours
        CHECK (allocated_hours >= 0)
    -- OPTIONAL: avkommentera för att tillåta max en rad per kombo
    -- ,CONSTRAINT uq_ta_emp_ci_activity
    --     UNIQUE (employee_id, course_instance_id, activity_type_id)
);
