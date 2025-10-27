/**
 * IT5008 Tutorial 05
 * Script adapted by Henry Heng
 */

/** For Question 1 */

-- Question 1a
SELECT DISTINCT d.department
FROM department d
WHERE d.faculty = 'School of Computing';

-- Question 1b (refer to T02 Q2b)
SELECT DISTINCT s.email
FROM student s, loan l
WHERE (s.email = l.borrower OR s.email = l.owner)
  AND s.year > l.borrowed;

-- Alternative(s) for Question 1b
SELECT DISTINCT s.email
FROM student s
  INNER JOIN loan l ON (s.email = l.borrower OR s.email = l.owner)
                    AND s.year > l.borrowed;

SELECT s1.email
FROM student s1, loan l1
WHERE s1.email = l1.borrower
  AND s1.year > l1.borrowed
UNION
SELECT s2.email
FROM student s2, loan l2
WHERE s2.email = l2.borrower
  AND s2.year > l2.borrowed;

-- Question 1c (refer to T02 Q2e)
SELECT s.email
FROM loan l, student s
WHERE s.email = l.borrower AND l.borrowed = s.year
EXCEPT
SELECT s.email
FROM loan l, student s
WHERE s.email = l.owner AND l.borrowed = s.year;

/** For Question 2 */

-- STEP 1: Find email and names of students who did not borrow any book authored by 'Adam Smith'.

-- Step 1a: Find all combinations of "email", "name" belonging to students, "isbn13" of books authored by 'Adam Smith'.
-- Q2 fulfills the first part of the step; Q1 is part of the process

-- Q1 := Select all books authored by 'Adam Smith'
SELECT b1.isbn13
FROM book b1
WHERE b1.authors = 'Adam Smith';

-- Q2 := Include selection of students to show who borrowed books authored by 'Adam Smith'
SELECT s1.email, s1.name, b1.isbn13
FROM student s1, book b1
WHERE b1.authors = 'Adam Smith';


-- Step 1b: Result of Step 1a, except combination of students who borrowed books by 'Adam Smith' (Q3)
-- Q4 fulfills the remaining part of the whole step; Q3 is what to exclude

-- Q3 := Basically Q2, but those records that are found in the "loan" table
SELECT s2.email, s2.name, b2.isbn13
FROM student s2, book b2, loan l2
WHERE b2.authors = 'Adam Smith'
  AND l2.book = b2.isbn13
  AND l2.borrower = s2.email; 

-- Q4 := Select emails and names from the result of Q2-Q3
-- Note that Q2 and Q3 are union-compatible (i.e., same columns selected)
SELECT email, name      -- to present union-compatibility for Q5
FROM (
  SELECT s1.email, s1.name, b1.isbn13
  FROM student s1, book b1
  WHERE b1.authors = 'Adam Smith'
  EXCEPT
  SELECT s2.email, s2.name, b2.isbn13
  FROM student s2, book b2, loan l2
  WHERE b2.authors = 'Adam Smith'
    AND l2.book = b2.isbn13
    AND l2.borrower = s2.email
);

-- STEP 2: Email and names of all students (incl. those who didn't borrow) except those in Q4
-- Q5 fulfills this step entirely, and is the solution overall

SELECT s3.email, s3.name
FROM student s3
EXCEPT
SELECT tmp.email, tmp.name    -- "tmp" alias for clarity
FROM (
  SELECT s1.email, s1.name, b1.isbn13
  FROM student s1, book b1
  WHERE b1.authors = 'Adam Smith'
  EXCEPT
  SELECT s2.email, s2.name, b2.isbn13
  FROM student s2, book b2, loan l2
  WHERE b2.authors = 'Adam Smith'
    AND l2.book = b2.isbn13
    AND l2.borrower = s2.email
) AS tmp;

