-- Q1a Aggregate without GROUP BY
SELECT COUNT(*)
FROM loan l, student s1, student s2
WHERE l.owner = s1.email
  AND l.borrower = s2.email
  AND s1.department = s2.department;


-- Q1b Aggregate with GROUP BY
SELECT d1.faculty, COUNT(*)
FROM loan l, student s1, student s2, department d1, department d2
WHERE l.owner = s1.email
  AND l.borrower = s2.email
  AND s1.department = d1.department
  AND s2.department = d2.department
  AND d1.faculty = d2.faculty
GROUP by d1.faculty;


-- Q1c Alternative 1: Without Nested
SELECT CEIL(AVG((CASE
      WHEN l.returned ISNULL THEN CURRENT_DATE
      ELSE l.returned
    END) - l.borrowed + 1)),
  CEIL(STDDEV_POP((CASE
      WHEN l.returned ISNULL THEN CURRENT_DATE
      ELSE l.returned
    END ) - l.borrowed + 1))
FROM loan l;


-- Q1c Alternative 2: With Nested
SELECT CEIL(AVG(temp.duration)), CEIL(STDDEV_POP(temp.duration))
FROM (
    SELECT((CASE
        WHEN l.returned ISNULL THEN CURRENT_DATE
        ELSE l.returned
      END ) - l.borrowed + 1) AS duration
    FROM loan l
) AS temp;


-- Q2a Alternative 1: Nested with NOT IN
SELECT b.title
FROM book b
WHERE b.ISBN13 NOT IN (
  SELECT l.book
  FROM loan l);


-- Q2a Alternative 2: Nested with ALL
SELECT b.title
FROM book b
WHERE b.ISBN13 <> ALL (
  SELECT l.book
  FROM loan l);
-- x NOT IN s  ===  forall y IN S : x <> y


-- Q2b Alternative 1: Doubly Nested with IN
SELECT s.name
FROM student s
WHERE s.email IN (
  SELECT c.owner
  FROM copy c
  WHERE NOT EXISTS (
    SELECT *
    FROM loan l
    WHERE l.owner = c.owner
      AND l.book = c.book
      AND l.copy = c.copy));


-- Q2b Alternative 2: Doubly Nested with ANY
SELECT s.name
FROM student s
WHERE s.email = ANY (
  SELECT c.owner
  FROM copy c
  WHERE NOT EXISTS (
    SELECT *
    FROM loan l
    WHERE l.owner = c.owner
      AND l.book = c.book
      AND l.copy = c.copy));


-- Q2b Alternative 3: Tuple Construction (postgresql)
SELECT s.name
FROM student s
WHERE s.email IN (
  SELECT c.owner
  FROM copy c
  WHERE (c.owner, c.book, c.copy) NOT IN ( -- this line may not work
    SELECT l.owner, l.book, l.copy
    FROM loan l));


-- Q2b Incorrect Query
-- INCORRECT
SELECT s.name
FROM student s, copy c
WHERE s.email = c.owner
AND NOT EXISTS (
  SELECT *
  FROM loan l
  WHERE l.owner = c.owner
    AND l.book = c.book
    AND l.copy = c.copy);


-- Q2c Nested with HAVING
SELECT s.department, s.name, COUNT(*)
FROM student s, loan l
WHERE l.owner = s.email
GROUP BY s.department, s.email, s.name
HAVING COUNT(*) >= ALL (
  SELECT COUNT(*)
  FROM student s1, loan l1
  WHERE l1.owner = s1.email
    AND s.department = s1.department
  GROUP BY s1.email);


-- Q2d Test Case
INSERT INTO loan VALUES
  ('nihanran1989@msn.com', 'choyweixiang2011@gmail.com',
   '978-0553585971', 1, '2024-03-10', NULL);


-- Q2d Universal Quantification
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


