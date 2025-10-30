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
SELECT d1.faculty,
    COUNT(*)
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
GROUP BY d1.faculty;
-- because d1.faculty is used in SELECT(), and COUNT() is an aggregate function, GROUP BY needs to be used
-- ANS : 
--      faculty                             | count
--      Faculty of Arts and Social Science  | 263
--      Faculty of Engineering              | 49
--      Faculty of Science                  | 155
--      Faculty of Computing                | 342
-- (c) : What are the average and the standard deviation [3] of the duration of a loan in days?
SELECT AVG(
        (
            CASE
                WHEN l.returned ISNULL THEN CURRENT_DATE
                ELSE l.returned
            END
        ) - L.borrowed + 1
    ) AS AVERAGE,
    STDDEV(
        (
            CASE
                WHEN l.returned ISNULL THEN CURRENT_DATE
                ELSE l.returned
            END
        ) - L.borrowed + 1
    ) AS STANDARD_DEVIATION
FROM loan l;
-- ANS : 
--      AVERAGE             | STANDARD_DEVIATION
--      54.9778956675508400 | 108.315899673610
-- ISSUE : As per answer key, both AVG and STD is rounded up to the nearest whole number
--          USE CEIL to achieve that
;
-- 2. Nested Queries.
-- (a) : Print the titles of the diﬀerent books that have never been borrowed. Use a nested
-- query.
SELECT b.title
FROM book b
WHERE B.ISBN13 NOT IN (
        SELECT l.book
        FROM loan l
    );
-- ANS : No table available (No books that has never been borrowed)
-- QNS: What is the difference between different titles and different books? Why is using DISTINCT wrong?
;
-- (b) : Print the name of the diﬀerent students who own a copy of a book that they have
-- never lent to anybody.
SELECT s.name
FROM student s
WHERE s.email = ANY (
        -- ANY : returns TRUE if ANY of the subquery values meet the condition
        SELECT c.owner
        FROM copy c
        WHERE NOT EXISTS (
                SELECT *
                FROM loan l
                WHERE l.owner = c.owner
                    AND l.book = c.book
                    AND l.copy = c.copy
            )
    );
-- Logic of this question : The students email who appeaered in copy table cannot exist in loan table, but we want to return student names, so we have to use student table
-- ANS : 
--          name
--      "SIOW CAO KHOA"
--      "NGOO KAI TING"
--      "LIU ZHENCAI"
--      "CHOY YI TING"
--      "ZHANG ZHANPENG"
--      "PENG JIAYUAN"
-- QN : Below is the initial answer, why is this wrong? 
-- SELECT s.name 
-- FROM student s
-- WHERE s.email IN (
--     SELECT c.owner
--     FROM copy c, loan l
--     WHERE c.owner NOT IN l.owner
-- )
--     )
-- ); 
-- (c) : For each department, print the names of the students who lent the most.
SELECT s.name,
    s.department,
    COUNT(*)
FROM student s,
    loan l
WHERE l.owner = s.email
GROUP BY s.name,
    s.department
HAVING COUNT(*) >= ALL (
        --  ALL : condition will be true only if the operation is true for all values in the range. 
        SELECT COUNT(*) -- HAVING : since an aggregate (COUNT) is being filtered, use HAVING 
        FROM student s1,
            loan l1
        WHERE l1.owner = s1.email
            AND s.department = s1.department
        GROUP BY s1.email
    );
-- ANS : 
--          name            |   department      |   count
--      "NEHAL KANWAT"      |   "Language"      |   42
--      "ANUPAMA ANGHAN"    |   "CE"            |   44
--      "ANNIE CHAPMAN"     |   "Language"      |   42
--      "ZHANG HONG"        |   "IS"            |   67
--      "PENG JIAYUAN"      |   "Biology"       |   55
--      "ZENG YIHUI"        |   "History"       |   45
--      "GE DUO"            |   "ME"            |   39
--      "NI HANRAN"         |   "Physics"       |   47
--      "HUANG WENXIN"      |   "Math"          |   49
--      "WANG NA"           |   "EE"            |   43
--      "LI YUZHAO"         |   "Economics"     |   43
--      "XIE XIN"           |   "Chemistry"     |   37
--      "ZHANG YUZHAO"      |   "Geography"     |   48
--      "TAY YONG MING"     |   "CE"            |   44
--      "SIOW CAO KHOA"     |   "CS"            |   47
;
-- (d) : Print the emails and the names of the diﬀerent students who borrowed all the books
-- authored by Adam Smith.
SELECT s.email,
    s.name
FROM student s
WHERE NOT EXISTS (
        SELECT *
        FROM book b
        WHERE authors = 'Adam Smith'
            AND NOT EXISTS (
                SELECT *
                FROM loan l
                WHERE l.book = b.ISBN13
                    AND l.borrower = s.email
            )
    );
-- ANS : No table available 
-- TODO: Read this question again and fully understand it!! (AKA Universal Quantification)