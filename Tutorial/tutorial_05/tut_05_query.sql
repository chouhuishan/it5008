-- σ : Similar to WHERE clause in SQL
;
-- Example 1
--      SELECT *
--      FROM restaurant r
--      WHERE r.area = 'London';
-- The code above will be represented: σ[area = 'London'](restaurant)
;
-- ∧ : Represent AND
-- ∨ : Represent OR
;
-- Example 2
--      SELECT *
--      FROM sells s
--      WHERE (s.pizza = 'Veggie'
--              AND s.price < 14)
--      OR (s.rname = 'Sizzle Grill')
-- The code above will be represented: σ[(pizza = 'Veggie' ∧ price < 14)
--                                      ∨ (rname = 'Sizzle Grill')](sells)
;
-- π : Similar SELECT clause in SQL
-- Example 3:
--      SELECT DISTINCT l.cname
--      FROM likes l;
-- The code above will be represented: π[cname](likes)
;
-- Building onto Example 2: 
-- The code will become: 
-- π[rname](
--   σ[(pizza = 'Veggie' ∧ price < 14)
--     ∨ (rname = 'Sizzle Grill')](sells))
;
-- ρ is used to rename the relations
-- Example 4:
--      SELECT DISTINCT r.attr ➡️ (3)
--      FROM rel r ➡️ (1)
--      WHERE c; ➡️ (2)
-- The code above will be represented: 
-- π[r.attr]( ➡️ (3) ; SELECT
--   σ[c]( ➡️ (2) ; WHERE
--     ρ(rel, r))) r ➡️ (1) ; FROM
;
-- ⋈ : Represents INNER JOIN
-- EXAMPLE 5
-- SELECT DISTINCT a1, a2, a3, ...
-- FROM r1 JOIN r2 ON c1
--         JOIN r3 ON c2;
-- The code above will be represented: 
-- π[a1, a2, a3, ...](
--   r1 ⋈[c1] r2 ⋈[c2] r3
-- ) 
-- # (r1 ⋈[c1] r2) ⋈[c2] r3
;
-- 1. Relational Algebra 
-- (a) Find the different departments in School of Computing.
SELECT DISTINCT d.departments -- π
FROM departments d -- ρ
WHERE d.faculty = 'School of Computing' -- σ
;
-- π[d.department](σ[d.faculty = 'School of Computing'](ρ(department, d)))
;
-- (b) Let us check the integrity of the data. Find the emails of the students who borrowed
-- or lent a copy of a book before they joined the university. There should not be any.
SELECT s.email -- π
FROM student s,
    loan l -- ρ
WHERE (
        s.email = l.borrower
        OR s.email = l.owner
    )
    AND l.borrowed < s.year -- σ
;
-- π[s.email](σ[(s.email = l.borrower ∨ s.email = l.owner) ∧ (l.borrowed < s.year)]
-- (ρ(student, s) × ρ(loan, l)) 
--)
SELECT s.email
FROM student s
    INNER JOIN loan l ON (
        s.email = l.borrower
        OR s.email = l.owner
    )
    AND l.borrowed < s.year;
-- π[s.email](ρ(student, s) ⋈ [(s.email = l.borrower ∨ s.email = l.owner) ∧ (l.borrowed < s.year)]
-- ρ(loan, l)
-- )
SELECT s1.email
FROM loan l1,
    student s1
WHERE s1.email = l1.borrower
    AND l1.borrowed < s1.year
UNION
SELECT s2.email
FROM loan l2,
    student s2
WHERE s2.email = l2.owner
    AND l2.borrowed < s2.year;
-- π[s1.email](σ[s1.email = l1.borrower ∧ l1.borrowed < s1.year]
--(ρ(student, s1) × ρ(loan, l1))
-- )
-- ∪
-- π[s2.email](σ[s2.email = l2.owner ∧ l1.borrowed < s1.year]
--(ρ(student, s2) × ρ(loan, l2))
-- )
;
-- (c) Print the emails of the students who borrowed but did not lend a copy of a book on
-- the day that they joined the university.
SELECT s1.email
FROM loan l1,
    student s1
WHERE s1.email = l1.borrower
    AND l1.borrowed < s1.year
EXCEPT
SELECT s2.email
FROM loan l2,
    student s2
WHERE s2.email = l2.borrower
    AND l2.borrowed < s2.year;
-- π[s1.email](σ[s1.email = l1.borrower ∧ l1.borrowed < s1.year]
--(ρ(student, s1) × ρ(loan, l1))
-- )
-- -
-- π[s2.email](σ[s2.email = l2.owner ∧ l1.borrowed < s1.year]
--(ρ(student, s2) × ρ(loan, l2))
-- )
;
-- 2. Universal Quantification
-- Print the emails and the names of the different students who borrowed all the books
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
-- Problem : NOT EXISTS is not direcly translatable to relational algebra
-- Q1 := π[b1.ISBN13](σ[b1.authors='Adam Smith'](ρ(book, b1)))
-- ⇒ The ISBN13 of all books authored by Adam Smith.
-- Q2 : = π[s1.email,s1.name](ρ(student, s1)) × Q1
-- Q1 and Q2 are written in query:
SLECT s1.email,
s1.name,
b1.ISBN13
FROM student s1,
    book b1
WHERE b1.authors = 'Adam Smith';
-- Q3 : = π[s2.email,s2.name,b2.ISBN13](
-- ρ(loan, l2) ▷◁[l2.book=b2.ISBN13 ∧ b2.authors='Adam Smith'] ρ(book, b2)
-- ▷◁[l2.borrower=s2.email] ρ(student, s2))
-- ⇒ Students who have borrowed books by Adam Smith (results to exclude)
-- Q3 are written in query:
SELECT s2.email,
    s2.name,
    b2.ISBN13
FROM loan l2
    INNER JOIN book b2 ON l2.book = b2.ISBN13
    AND b2.authors = 'Adam Smith'
    INNER JOIN student s2 ON l2.borrower = s2.email;
-- Q4 := π[s2.email,s2.name](Q2− Q3) 
-- NOTE : Q2 and Q3 are union - compatible (same columns)
-- Q5 := π [s3.email,s3.name](ρ(student, s3)) − Q4
;
-- Final overall answer:
SELECT s3.email,
    s3.name
FROM student s3
EXCEPT
SELECT tmp.email,
    tmp.name
FROM (
        SELECT s1.email,
            s1.name,
            b1.ISBN13
        FROM student s1,
            book b1
        WHERE b1.authors = 'Adam Smith'
        EXCEPT
        SELECT s2.email,
            s2.name,
            b2.ISBN13
        FROM student s2,
            book b2,
            loan l2
        WHERE b2.authors = 'Adam Smith'
            AND s2.email = l2.borrower
            AND b2.ISBN13 = l2.book
    ) AS tmp;