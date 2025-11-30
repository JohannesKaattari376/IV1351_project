
-- QUERY 1: PLANNED HOURS (PER COURSE INSTANCE, CURRENT YEAR)


CREATE OR REPLACE VIEW v_planned_hours_current_year AS
SELECT
    c.course_code,
    ci.course_instance_id,
    ci.hp,
    ci.period_code AS period,
    ci.num_students,
    COALESCE(SUM(pa.planned_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Lecture'), 0) AS lecture_hours,
    COALESCE(SUM(pa.planned_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Tutorial'), 0) AS tutorial_hours,
    COALESCE(SUM(pa.planned_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Lab'), 0) AS lab_hours,
    COALESCE(SUM(pa.planned_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Seminar'), 0) AS seminar_hours,
    COALESCE(SUM(pa.planned_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Other'), 0) AS other_overhead_hours,
    (2 * ci.hp + 28 + 0.2 * ci.num_students)      AS admin_hours,
    (32 + 0.725 * ci.num_students)                AS exam_hours,
    (
        COALESCE(SUM(pa.planned_hours * tat.factor)
                 FILTER (WHERE tat.activity_name = 'Lecture'), 0)
      + COALESCE(SUM(pa.planned_hours * tat.factor)
                 FILTER (WHERE tat.activity_name = 'Tutorial'), 0)
      + COALESCE(SUM(pa.planned_hours * tat.factor)
                 FILTER (WHERE tat.activity_name = 'Lab'), 0)
      + COALESCE(SUM(pa.planned_hours * tat.factor)
                 FILTER (WHERE tat.activity_name = 'Seminar'), 0)
      + COALESCE(SUM(pa.planned_hours * tat.factor)
                 FILTER (WHERE tat.activity_name = 'Other'), 0)
      + (2 * ci.hp + 28 + 0.2 * ci.num_students)
      + (32 + 0.725 * ci.num_students)
    ) AS total_hours
FROM
    course_instance ci
    JOIN course c ON c.course_code = ci.course_code
    LEFT JOIN planned_activity pa
           ON pa.course_instance_id = ci.course_instance_id
    LEFT JOIN teaching_activity_type tat
           ON tat.activity_type_id = pa.activity_type_id
WHERE
    ci.year = 2025
GROUP BY
    c.course_code,
    ci.course_instance_id,
    ci.hp,
    ci.period_code,
    ci.num_students;

-- QUERY 2: ALLOCATED HOURS PER TEACHER FOR ONE COURSE INSTANCE

CREATE OR REPLACE VIEW v_allocated_hours_per_teacher_example AS
SELECT
    c.course_code,
    ci.course_instance_id,
    ci.hp,
    (e.first_name || ' ' || e.last_name) AS teacher_name,
    jt.title AS designation,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Lecture'), 0) AS lecture_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Tutorial'), 0) AS tutorial_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Lab'), 0) AS lab_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Seminar'), 0) AS seminar_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Other'), 0) AS other_overhead_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Admin'), 0) AS admin_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Exam'), 0) AS exam_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor), 0) AS total_hours
FROM
    teaching_allocation ta
    JOIN employee e   ON e.employee_id = ta.employee_id
    JOIN job_title jt ON jt.job_title_id = e.job_title_id
    JOIN course_instance ci ON ci.course_instance_id = ta.course_instance_id
    JOIN course c      ON c.course_code = ci.course_code
    JOIN teaching_activity_type tat
         ON tat.activity_type_id = ta.activity_type_id
WHERE
    ci.year = 2025
    AND ci.course_instance_id = '2025-50273'   -- change if needed
GROUP BY
    c.course_code,
    ci.course_instance_id,
    ci.hp,
    teacher_name,
    jt.title
ORDER BY
    teacher_name;

-- QUERY 3: TOTAL ALLOCATED HOURS PER TEACHER (CURRENT YEAR)

CREATE OR REPLACE VIEW v_teacher_load_current_year_example AS
SELECT
    c.course_code,
    ci.course_instance_id,
    ci.hp,
    ci.period_code AS period,
    (e.first_name || ' ' || e.last_name) AS teacher_name,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Lecture'), 0) AS lecture_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Tutorial'), 0) AS tutorial_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Lab'), 0) AS lab_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Seminar'), 0) AS seminar_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Other'), 0) AS other_overhead_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Admin'), 0) AS admin_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor)
             FILTER (WHERE tat.activity_name = 'Exam'), 0) AS exam_hours,
    COALESCE(SUM(ta.allocated_hours * tat.factor), 0) AS total_hours
FROM
    teaching_allocation ta
    JOIN employee e   ON e.employee_id = ta.employee_id
    JOIN course_instance ci ON ci.course_instance_id = ta.course_instance_id
    JOIN course c      ON c.course_code = ci.course_code
    JOIN teaching_activity_type tat
         ON tat.activity_type_id = ta.activity_type_id
WHERE
    ci.year = 2025
    AND e.employment_id = 'E101'    -- change to the teacher you want
GROUP BY
    c.course_code,
    ci.course_instance_id,
    ci.hp,
    ci.period_code,
    teacher_name
ORDER BY
    ci.period_code,
    c.course_code,
    ci.course_instance_id;

-- QUERY 4: TEACHERS ALLOCATED TO MORE THAN N COURSES IN A PERIOD

CREATE OR REPLACE VIEW v_overloaded_teachers_example AS
SELECT
    e.employment_id,
    (e.first_name || ' ' || e.last_name) AS teacher_name,
    ci.period_code AS period,
    COUNT(DISTINCT ci.course_instance_id) AS num_courses
FROM
    teaching_allocation ta
    JOIN employee e        ON e.employee_id = ta.employee_id
    JOIN course_instance ci ON ci.course_instance_id = ta.course_instance_id
WHERE
    ci.year = 2025
    AND ci.period_code = 'P1'     -- current period
GROUP BY
    e.employment_id,
    teacher_name,
    ci.period_code
HAVING
    COUNT(DISTINCT ci.course_instance_id) > 1    -- threshold
ORDER BY
    num_courses DESC,
    teacher_name;
