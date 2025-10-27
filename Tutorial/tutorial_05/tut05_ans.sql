-- Q1a Simple Query (one table)
SELECT d.department
FROM department d
WHERE d.faculty = 'School of Computing';


-- Q1b Alternative 1: Simple Query (multiple tables)
SELECT s.email
FROM student s, loan l
WHERE (s.email = l.borrower OR s.email = l.owner)
  AND l.borrowed < s.year;


-- Q1b Alternative 2: Algebraic Query (INNER JOIN)
SELECT s.email
FROM student s
  INNER JOIN loan l ON (s.email = l.borrower OR s.email = l.owner)
                    AND l.borrowed < s.year;


-- Q1b Alternative 3: Algebraic Query (UNION)
SELECT s1.email
FROM loan l1, student s1
WHERE s1.email = l1.borrower
  AND l1.borrowed < s1.year
UNION
SELECT s2.email
FROM loan l2, student s2
WHERE s2.email = l2.borrower
  AND l2.borrowed < s2.year


-- Q1c Algebraic Query (EXCEPT)
SELECT s1.email
FROM loan l1, student s1
WHERE s1.email = l1.borrower
  AND l1.borrowed < s1.year
EXCEPT
SELECT s2.email
FROM loan l2, student s2
WHERE s2.email = l2.borrower
  AND l2.borrowed < s2.year


-- Q2a Nested Query (hard to make algebraic)
SELECT s.email, s.name
FROM student s
WHERE NOT EXISTS (
  SELECT *
  FROM book b
  WHERE authors = 'Adam Smith'
    AND NOT EXISTS (
      SELECT *
      FROM loan l
      WHERE l.book = b.ISBN13
      AND l.borrower = s.email));


-- Q2a Universal quantification algebraically
SELECT s3.email, s3.name
FROM student s3
EXCEPT
SELECT tmp.email, tmp.name
FROM (
  SELECT s1.email, s1.name, b1.ISBN13
  FROM student s1, book b1
  WHERE b1.authors = 'Adam Smith'
  EXCEPT
  SELECT s2.email, s2.name, b2.ISBN13
  FROM student s2, book b2, loan l2
  WHERE b2.authors = 'Adam Smith'
    AND s2.email = l2.borrower
    AND b2.ISBN13 = l2.book
) AS tmp;


