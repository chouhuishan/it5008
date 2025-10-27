-- TUTORIAL 4: SQL: Aggregate and Nested Queries
-- 1. Aggregate Queries.
-- (a) : How many loans involve an owner and a borrower from the same department?
SELECT COUNT(*)
FROM loan l,
    student s1,
    student s2
WHERE l.borrower = s1.email
    AND l.owner = s2.email
    AND s1.department = s2.department;
-- ANS: 335
-- (b): For each faculty, print the number of loans that involve an owner and a borrower from
-- this faculty?
SELECT COUNT(*)
FROM loan l,
    student s1,
    student s2