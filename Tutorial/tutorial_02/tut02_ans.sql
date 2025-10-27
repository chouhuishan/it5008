-- Q1a Simple Query
SELECT d.department
FROM department d;


-- Q1b Simple Query with DISTINCT
SELECT DISTINCT s.department
FROM student s;


-- Q1c Alternative 1
SELECT l.book, l.returned - l.borrowed + 1 AS duration
FROM loan l
WHERE l.returned IS NOT NULL -- equivalently NOT (l.returned ISNULL)
ORDER BY l.book ASC, duration DESC;


-- Q1c Alternative 2: with COALESCE
SELECT l.book,
  (COALESCE(l.returned, CURRENT_DATE) - l.borrowed + 1) AS duration
FROM loan l
ORDER BY l.book ASC, duration DESC;


-- Q1c Alternative 3: with CASE WHEN
SELECT l.book,
  ((CASE 
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1) AS duration
FROM loan l
ORDER BY l.book ASC, l.duration DESC;


-- Q2a Alternative 1: Using all relevant tables
SELECT b.title,
  s1.name AS ownerName,
  d1.faculty AS ownerFaculty,
  s2.name AS borrowerName,
  d2.faculty AS borrowerFaculty
FROM loan l, book b, copy c,
  student s1, student s2,
  department d1, department d2
WHERE l.book = b.ISBN13
  AND c.book = l.book
  AND c.copy = l.copy
  AND c.owner = l.owner
  AND l.owner = s1.email
  AND l.borrower = s2.email
  AND s1.department = d1.department
  AND s2.department = d2.department
  AND b.publisher = 'Wiley'
  AND l.returned ISNULL;


-- Q2a Alternative 2: With simplification
SELECT b.title,
  s1.name AS ownerName,
  d1.faculty AS ownerFaculty,
  s2.name AS borrowerName,
  d2.faculty AS borrowerFaculty
FROM loan l, book b, -- no more copy table
  student s1, student s2,
  department d1, department d2
WHERE l.book = b.ISBN13
  AND l.owner = s1.email
  AND l.borrower = s2.email
  AND s1.department = d1.department
  AND s2.department = d2.department
  AND b.publisher = 'Wiley'
  AND l.returned ISNULL;


-- Q2a Replace Cartesian with INNER JOIN
SELECT b.title,
  s1.name AS ownerName,
  d1.faculty AS ownerFaculty,
  s2.name AS borrowerName,
  d2.faculty AS borrowerFaculty
FROM loan l
  INNER JOIN book b ON l.book = b.ISBN13
  INNER JOIN student s1 ON l.owner = s1.email
  INNER JOIN student s2 ON l.borrowed = s2.email
  INNER JOIN department d1 ON s1.department = d1.department
  INNER JOIN department d2 ON s2.department = d2.department
WHERE b.publisher = 'Wiley' AND l.returned ISNULL;


-- Q2b Alternative 1
SELECT DISTINCT s.email
FROM loan l, student s
WHERE (s.email = l.borrower OR s.email = l.owner)
  AND l.borrowed < s.year;


-- Q2b Alternative 2
SELECT DISTINCT s.email
FROM loan l, student s
WHERE (s.email = l.borrower AND l.borrowed < s.year)
   OR (s.email = l.owner AND l.borrowed < s.year);
   -- (x OR y) AND z  ===  (x AND z) OR (x AND y)


-- Q2c Simple Query
SELECT DISTINCT s.email
FROM loan l, student s
WHERE (s.email = l.borrower OR s.email = l.owner)
  AND l.borrowed = s.year;
  -- Can you rewrite this with INNER JOIN?


-- Q2c use UNION
SELECT s.email
FROM loan l, student s
WHERE s.email = l.borrower AND l.borrowed = s.year
UNION
SELECT s.email
FROM loan l, student s
WHERE s.email = l.owner AND l.borrowed = s.year;


-- Q2d use INTERSECT
SELECT s.email
FROM loan l, student s
WHERE s.email = l.borrower AND l.borrowed = s.year
INTERSECT
SELECT s.email
FROM loan l, student s
WHERE s.email = l.owner AND l.borrowed = s.year;


-- Q2d no INTERSECT
SELECT DISTINCT s.email
FROM loan l1, loan l2, student s
WHERE s.email = l1.borrower AND l1.borrowed = s.year
  AND s.email = l2.owner AND l2.borrowed = s.year;
  -- Can you rewrite this with INNER JOIN?


-- Q2e use EXCEPT
SELECT s.email
FROM loan l, student s
WHERE s.email = l.borrower AND l.borrowed = s.year
EXCEPT
SELECT s.email
FROM loan l, student s
WHERE s.email = l.owner AND l.borrowed = s.year;


-- Q2f Unmatched rows with EXCEPT
SELECT b.ISBN13
FROM book b
EXCEPT
SELECT l.book
FROM loan l;


-- Q2f Unmatched rows with OUTER JOIN
SELECT b.ISBN13
FROM book b LEFT OUTER JOIN loan l ON b.ISBN13 = l.book
WHERE l.book ISNULL;


