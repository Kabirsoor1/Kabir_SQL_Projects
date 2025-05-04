/* University Database -- SQL Project

Exploratory Questions
1. How many students enrolled each year?
2. Which courses have the highest number of enrollments?
3. What is the average grade per course?

Performance Analysis
4. What is the average GPA per department?
5. What is the average GPA for each course, and does the course meet the pass threshold of a GPA of 2.0?
5b.What is the pass/fail rate for each course?

Join-Based Insights
6. Which students took the most total credits in a single semester?
7. List all students and the courses they are enrolled in, with course and department names.
8. Which students have enrolled in more than one course from the same department?

Temporal Trends
9. How has course enrollment changed over the semesters?
10. What is the grade distribution by semester?

Advanced Queries
11. Calculate each student's GPA and rank them.
12. Identify students who have failed at least two courses.
13. Which students have only taken courses within their major’s department?

*/

SELECT * 
from courses
;

SELECT *
from enrollments
;

SELECT *
from students
;

-- Exploratory Questions
-- 1) How many students enrolled each year?

SELECT enrollment_year, COUNT(enrollment_year) AS student_count
FROM students
GROUP BY enrollment_year
ORDER by enrollment_year
;

-- 2) Which courses have the highest number of enrollments?

SELECT *
from courses
;

SELECT course_id, COUNT(course_id) AS total_enrollments
from enrollments
GROUP by course_id
ORDER by total_enrollments DESC
;

-- the query below allowed me to attribute a course name to the course id, using a JOIN
SELECT enrollments.course_id, courses.course_name, COUNT(enrollments.course_id) AS total_enrollments
from enrollments
JOIN courses
ON enrollments.course_id = courses.course_id
GROUP by enrollments.course_id, courses.course_name
ORDER by total_enrollments DESC
;

-- 3. What is the average grade per course?

SELECT *
FROM enrollments
;

SELECT course_id, grade, 
CASE
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END gpa_grade
FROM enrollments
;


SELECT enrollments.course_id, courses.course_name, 
ROUND(AVG(CASE 
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END),2) gpa_grades 
FROM enrollments
JOIN courses
ON enrollments.course_id = courses.course_id
GROUP BY enrollments.course_id, courses.course_name
ORDER BY gpa_grades DESC
;

-- 4) What is the average GPA per department?

SELECT courses.department,
AVG(CASE
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END) gpa_grades_departments
from courses
join enrollments
ON courses.course_id = enrollments.course_id
GROUP BY courses.department
ORDER BY gpa_grades_departments DESC
;

-- 5. What is the average GPA for each course, and does the course meet the pass threshold of a GPA of 2.0?

SELECT *
FROM courses
;

WITH gpa_grades_courses AS
(SELECT enrollments.course_id, courses.course_name, 
ROUND(AVG(CASE 
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END),2) gpa_grades 
FROM enrollments
JOIN courses
ON enrollments.course_id = courses.course_id
GROUP BY enrollments.course_id, courses.course_name
ORDER BY gpa_grades DESC
)

SELECT course_id, course_name, gpa_grades,
CASE
WHEN gpa_grades >= '2' THEN 'Pass'
ELSE 'Fail'
END pass_fail
FROM gpa_grades_courses
;

-- 5b.What is the pass/fail rate for each course?

SELECT enrollments.course_id, courses.course_name,
SUM(CASE 
WHEN grade IN ('A', 'A-', 'A+', 'B', 'B-', 'B+', 'C', 'C-', 'C+') THEN '1'
ELSE '0'
END ) pass_rates,
SUM(CASE
WHEN grade IN ('D', 'D-', 'D+', 'F', 'F-', 'F+', 'E', 'E-', 'E+') THEN '1' ELSE '0'
END) fail_rates
FROM enrollments
JOIN courses
ON enrollments.course_id = courses.course_id
GROUP BY enrollments.course_id, courses.course_name
;

-- 6. Which students took the most total credits in a single semester?

SELECT e.student_id, first_name, last_name, major, semester, SUM(credits) AS total_credits
FROM enrollments AS e
JOIN courses AS c ON e.course_id = c.course_id
JOIN students AS s ON e.student_Id = s.student_id
GROUP BY e.student_id, first_name, last_name, major, semester
ORDER BY total_credits DESC
;

-- 7) List all students and the courses they are enrolled in, with course and department names.

SELECT first_name, last_name, course_name, department, semester
FROM students AS s
JOIN courses AS c
ON s.major = c.department
JOIN enrollments AS e
ON s.student_id = e.student_id
;

-- 8. Which students have enrolled in more than one course from the same department?

SELECT s.student_id, s.first_name, s.last_name, c.department, COUNT(*) AS courses_in_department
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.student_id
JOIN courses AS c ON e.course_id = c.course_id
GROUP BY s.student_id, s.first_name, s.last_name, c.department
HAVING COUNT(*) > 1
;

-- 9. How has course enrollment changed over the semesters?

SELECT semester, COUNT(semester)
FROM enrollments
GROUP BY semester
ORDER BY semester
;

-- 10. What is the grade distribution by semester?

SELECT semester, grade, COUNT(grade)
FROM enrollments
GROUP BY semester, grade
ORDER BY semester
;

-- 11. Calculate each student's GPA

SELECT s.student_id, first_name, last_name, 
ROUND(AVG(CASE
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END),2) avg_gpa_grade
FROM students AS s
JOIN enrollments AS e
ON s.student_id = e.student_id
GROUP BY student_id, first_name, last_name
ORDER by avg_gpa_grade DESC
;

-- 11b) Now rank them 

SELECT s.student_id, first_name, last_name, 
ROUND(AVG(CASE
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END),2) avg_gpa_grade,
dense_rank() OVER (ORDER BY ROUND(AVG(CASE
WHEN grade = 'A' THEN 4.0
WHEN grade = 'A-' THEN 3.7
WHEN grade = 'B+' THEN 3.3
WHEN grade = 'B' THEN 3.0
WHEN grade = 'B-' THEN 2.7
WHEN grade = 'C+' THEN 2.3
WHEN grade = 'C' THEN 2.0
WHEN grade = 'D' THEN 1.0
WHEN grade = 'F' THEN 0.0
ELSE NULL
END),2) DESC ) AS avg_gpa_rank
FROM students AS s
JOIN enrollments AS e
ON s.student_id = e.student_id
GROUP BY student_id, first_name, last_name
ORDER by avg_gpa_grade DESC
;

-- 12. Identify students who failed courses.

SELECT s.student_id, first_name, last_name, major, department, grade
FROM students AS s
JOIN enrollments AS e ON s.student_id = e.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE grade NOT IN ('A', 'A+', 'A-', 'B', 'B+', 'B-', 'C', 'C+', 'C-')
GROUP BY s.student_id, first_name, last_name, major, department, grade
;

-- 12b. Identify students who have failed at least two courses

SELECT first_name, last_name, COUNT(*) AS failed_courses
FROM students AS s
JOIN enrollments AS e ON s.student_id = e.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE grade NOT IN ('A', 'A+', 'A-', 'B', 'B+', 'B-', 'C', 'C+', 'C-')
GROUP BY first_name, last_name
HAVING count(*) >= 2
;

-- 13. Which students have taken courses within their major’s department?

SELECT s.student_id, first_name, last_name, department, major, course_name
FROM students AS s
JOIN enrollments AS e ON s.student_id = e.student_id
JOIN courses AS C on e.course_id = c.course_id
WHERE department = major
ORDER BY student_id
;

-- 13b) How many courses did each student take?

SELECT s.student_id, first_name, last_name, COUNT(*)
FROM students AS s
JOIN enrollments AS e ON s.student_id = e.student_id
JOIN courses AS C on e.course_id = c.course_id
GROUP BY s.student_id, first_name, last_name
ORDER BY student_id
;
