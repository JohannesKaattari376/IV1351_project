-- =========================================
-- IV1351 Project – Test data
-- =========================================

-- Perioder
INSERT INTO period (period_code, description) VALUES
('P1', 'Period 1'),
('P2', 'Period 2'),
('P3', 'Period 3'),
('P4', 'Period 4');

-- Jobbtitlar
INSERT INTO job_title (title) VALUES
('Professor'),
('Senior Lecturer'),
('Lecturer');

-- Avdelningar (department_id blir 1, 2, ... pga SERIAL)
INSERT INTO department (department_name)
VALUES ('Computer Science'),
       ('Mathematics');

-- Anställda
INSERT INTO employee (employment_id, first_name, last_name, email, phone_number,
                      salary, department_id, job_title_id, manager_id)
VALUES
('E100', 'Anna',  'Andersson', 'anna.andersson@example.com', '070-1111111',
 50000, 1, 2, NULL),  -- Senior Lecturer, manager NULL
('E101', 'Björn', 'Berg',      'bjorn.berg@example.com',      '070-2222222',
 42000, 1, 3, 1),     -- Lecturer, manager Anna
('E200', 'Carina','Carlsson',  'carina.carlsson@example.com', '070-3333333',
 43000, 2, 3, NULL);  -- Lecturer, annan avdelning

-- Sätt managers i department
UPDATE department SET manager_id = 1 WHERE department_id = 1;
UPDATE department SET manager_id = 3 WHERE department_id = 2;

-- Kurser
INSERT INTO course (course_code, course_name, hp, min_students, max_students, department_id)
VALUES
('IV1351', 'Data Storage Paradigms', 7.5, 50, 250, 1),
('IX1500', 'Discrete Mathematics',   7.5, 50, 150, 2);

-- Kursinstanser (matchar ungefär exemplen i uppgiften)
INSERT INTO course_instance (course_instance_id, year, num_students, hp,
                             course_code, period_code)
VALUES
('2025-50273', 2025, 200, 7.5, 'IV1351', 'P2'),
('2025-50413', 2025, 150, 7.5, 'IX1500', 'P1');

-- Aktiviteter + multiplikationsfaktorer
INSERT INTO teaching_activity_type (activity_name, factor) VALUES
('Lecture',   3.6),
('Lab',       2.4),
('Tutorial',  2.4),
('Seminar',   1.8),
('Other',     NULL);

-- Planerade aktiviteter för IV1351 (exempel från uppgiften)
INSERT INTO planned_activity (course_instance_id, activity_type_id, planned_hours)
VALUES
('2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Lecture'),   20),
('2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Tutorial'),  80),
('2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Lab'),       40),
('2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Seminar'),   80),
('2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Other'),    650);

-- Planerade aktiviteter för IX1500
INSERT INTO planned_activity (course_instance_id, activity_type_id, planned_hours)
VALUES
('2025-50413', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Lecture'),   44),
('2025-50413', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Seminar'),   64),
('2025-50413', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Other'),    200);

-- Allokeringar (exempel)
INSERT INTO teaching_allocation (allocated_hours, employee_id, course_instance_id, activity_type_id)
VALUES
(20, 1, '2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Lecture')),
(40, 2, '2025-50273', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Lab')),
(44, 2, '2025-50413', (SELECT activity_type_id FROM teaching_activity_type WHERE activity_name = 'Lecture'));
