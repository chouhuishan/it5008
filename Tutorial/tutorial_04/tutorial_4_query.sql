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
;
-- (b): For each faculty, print the number of loans that involve an owner and a borrower from
-- this faculty?
SELECT COUNT(*),
    d1.faculty
FROM department d1,
    department d2,
    student s1,
    student s2,
    loan l
WHERE s1.email = l.owner
    AND s2.email = l.borrower
    AND s1.department = d1.department
    AND s2.department = d2.department
    AND d1.faculty = d2.faculty
GROUP BY d1.faculty -- because d1.faculty is used in SELECT(), and COUNT() is an aggregate function, GROUP BY needs to be used
    -- (c) : What are the average and the standard deviation [3] of the duration of a loan in days?
    SELE