-- Q2a SELECT
SELECT * FROM book;


-- Q2b INSERT INTO
INSERT INTO book VALUES (
  'An Introduction to Database Systems',
  'paperback',
  640,
  'English',
  'C. J. Date',
  'Pearson',
  '2003-01-01',
  '0321197844',
  '978-0201385908'
);


-- Q2c INSERT INTO
INSERT INTO book VALUES (
  'An Introduction to Database Systems',
  'paperback',
  640,
  'English',
  'C. J. Date',
  'Pearson',
  '2003-01-01',
  '0201385902',
  '978-0321197849'
);


-- Q2e INSERT INTO
INSERT INTO student (name, year, faculty, department) VALUES (
  'RIKKI TAVI',
  '2024-08-15',
  'School of Computing',
  'CS'
);


-- Q2f SELECT CS
SELECT *
FROM student
WHERE department = 'CS';


-- Q2f SELECT Computer Science
SELECT *
FROM student
WHERE department = 'Computer Science';


-- Q2g DELETE FROM
DELETE FROM student
WHERE department = 'chemistry';


-- Q2h DELETE FROM
DELETE FROM student
WHERE department = 'Chemistry';


-- Q3b Equivalent Transaction 1
BEGIN TRANSACTION;
  DELETE FROM book b WHERE b.ISBN13 = '978-0321197849';
  DELETE FROM copy c WHERE c.book = '978-0321197849';
END TRANSACTION;


-- Q3b SELECT book
-- Result is empty, because after line 3 the book has been deleted
SELECT *
FROM book b
WHERE b.ISBN13 = '978-0321197849';


-- Q3b SELECT copy
-- However, this is non-empty, despite having a FOREIGN KEY to book
-- => Intermediate state is inconsistent!
SELECT *
FROM copy c
WHERE c.book = '978-0321197849';


-- Q4a Loaned but not returned (unavailable)
SELECT owner, book, copy, returned
FROM loan
WHERE returned ISNULL;


-- Q4a ALTER TABLE copy
ALTER TABLE copy
DROP COLUMN available;


-- Q4a CREATE VIEW copy_view
CREATE OR REPLACE VIEW copy_view (owner, book, copy, available) AS (
  SELECT DISTINCT c.owner, c.book, c.copy,
  CASE
    WHEN EXISTS (
      SELECT * FROM loan l
      WHERE l.owner = c.owner
        AND l.book = c.book
        AND l.copy = c.copy
        AND l.returned ISNULL
    ) THEN 'FALSE'
    ELSE 'TRUE'
  END
  FROM copy c 
);

SELECT * FROM copy_view; -- use the view like a table


-- Q4a Cannot UPDATE View
UPDATE copy_view
SET owner = 'tikki@google.com'
WHERE owner = 'tikki@gmail.com';


-- Q4a DROP VIEW
DROP VIEW copy_view;


-- Q4b Modification
CREATE TABLE department (
  department VARCHAR (32) PRIMARY KEY,
  faculty VARCHAR (62) NOT NULL
);

INSERT INTO department
  SELECT DISTINCT department, faculty
  FROM student;

ALTER TABLE student
DROP COLUMN faculty;

ALTER TABLE student
ADD FOREIGN KEY (department) REFERENCES department (department);


