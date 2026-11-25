CREATE DATABASE IF NOT EXISTS StudentPerformance
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE StudentPerformance;

CREATE TABLE IF NOT EXISTS Students (
  student_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  roll_no VARCHAR(30) NOT NULL,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NULL,
  department VARCHAR(100) NULL,
  semester TINYINT UNSIGNED NULL,
  PRIMARY KEY (student_id),
  UNIQUE KEY uq_students_roll_no (roll_no),
  UNIQUE KEY uq_students_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Subjects (
  subject_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  subject_name VARCHAR(150) NOT NULL,
  max_marks DECIMAL(7,2) NOT NULL,
  PRIMARY KEY (subject_id),
  UNIQUE KEY uq_subjects_name (subject_name),
  CONSTRAINT chk_subjects_max_marks CHECK (max_marks > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Exams (
  exam_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  exam_name VARCHAR(150) NOT NULL,
  exam_date DATE NULL,
  PRIMARY KEY (exam_id),
  UNIQUE KEY uq_exams_name (exam_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Marks (
  student_id INT UNSIGNED NOT NULL,
  subject_id INT UNSIGNED NOT NULL,
  exam_id INT UNSIGNED NOT NULL,
  marks_obtained DECIMAL(7,2) NOT NULL,
  PRIMARY KEY (student_id, subject_id, exam_id),
  CONSTRAINT chk_marks_nonnegative CHECK (marks_obtained >= 0),
  CONSTRAINT fk_marks_student
    FOREIGN KEY (student_id) REFERENCES Students (student_id),
  CONSTRAINT fk_marks_subject
    FOREIGN KEY (subject_id) REFERENCES Subjects (subject_id),
  CONSTRAINT fk_marks_exam
    FOREIGN KEY (exam_id) REFERENCES Exams (exam_id)
) ENGINE=InnoDB;

INSERT IGNORE INTO Subjects (subject_name, max_marks) VALUES
  ('Database Management Systems', 100),
  ('Data Structures', 100),
  ('Operating Systems', 100),
  ('Computer Networks', 100),
  ('Software Engineering', 100);

CREATE OR REPLACE VIEW StudentResults AS
SELECT
  s.student_id,
  s.roll_no,
  s.name,
  e.exam_name,
  ROUND(100 * SUM(m.marks_obtained) / NULLIF(SUM(sub.max_marks), 0), 2) AS percentage,
  CASE
    WHEN SUM(CASE WHEN m.marks_obtained < 40 THEN 1 ELSE 0 END) = 0 THEN 'PASS'
    ELSE 'FAIL'
  END AS result
FROM Marks AS m
JOIN Students AS s ON s.student_id = m.student_id
JOIN Subjects AS sub ON sub.subject_id = m.subject_id
JOIN Exams AS e ON e.exam_id = m.exam_id
GROUP BY s.student_id, s.roll_no, s.name, e.exam_id, e.exam_name;
