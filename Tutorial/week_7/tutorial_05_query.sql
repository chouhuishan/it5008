-- 1(a) : Find the different departments in School of Computing.
-- π, σ, p , ∨, ∧, ⋈
-- π[d.department](σ[d.faculty = 'school of computing'](p(department, d)))
SELECT DISTINCT d.department
FROM department d
WHERE department d;
-- 1(b) : Let us check the integrity of the data. Find the emails of the students who borrowed
-- or lent a copy of a book before they joined the university. There should not be any.
-- π [s.email](σ[(s.email = l.borrower ∨  s.email = l.owner) ∧ (s,year > l.borrower)](σ[(s.email = l.borrower ∨  s.email = l.owner) ∧ (s,year > l.borrower)]))
SELECT DISTINCT s.email
FROM student s,
    loan l
WHERE (
        s.email = l.borrower
        OR s.email = l.owner
    )
    AND s.year > l.borrower;
-- π[s.email](p(student.s) ⋈ [(s.email = l.borrower ∧ s.email = l.owner) ∧ (s.year > l.borrower)])
SELECT DISTINCT s.email
FROM student s
    INNER JOIN loan l ON (
        s.email = l.borrower
        OR s.email = l.owner
    )
    AND s.year > l.borrowed;
-- π(s1.email(σ(s1.email = l1.borrower ∧ s1.year > l1.borrowed)(p(student, s1) * p(loan, l1))))
-- π(s2.email(σ(s2.email = l2.owner ∧ s2.year > l2.borrowed)(p(student, s2) * p(loan, l2))))
SELECT s1.email
FROM student s1 = loan l1
WHERE s1.email = l1.borrower
    AND s1.year > l1.borrowed
UNION
SELECT s2.email
FROM student s2 = loan l2
WHERE s2.email = l2.owner
    AND s2.year > l2.borrowed;
-- 1(c) : Print the emails of the students who borrowed but did not lend a copy of a book on
-- the day that they joined the university.
-- sets is a very useful function in this question (Recall back from IT5001)
-- π[s1.email](σ[s1.email = l1.borrower ∧ s1.year = l1.borrowed](p(student, s1) * p(loan, l1)))
-- π[s2.email](σ[s2.email = l2.owner ∧ s2.year = l2.borrowed](p(student, s1) * p(loan, l2)))
SELECT s1.email
FROM student s1 = loan l1
WHERE s1.email = l1.borrower
    AND s1.year = l1.borrowed
EXCEPT
SELECT s2.email
FROM student s2 = loan l2
WHERE s2.email = l2.owner
    AND s2.year = l2.borrowed;
-- 2. Print the emails and the names of the different students who borrowed all the books
-- authored by Adam Smith
SELECT s3.email,
    s3.name
FROM student s3
EXCEPT
SELECT tmp.email,
    tmp.name
FROM (
        SELECT s1.email,
            s1.name,
            b1.isbn13 -- Q1 = π[b1.isbn13](σ[b1.authors = 'Adam Smith'](p(book, b)))
        FROM student s1,
            book b1
        WHERE b1.authors = 'Adam Smith';
EXCEPT
SELECT s2.email,
    s2.name,
    b2.isbn13 -- Q2 = π[s1.email, s1.name](p(student, s1)) * Q1
FROM student s2,
    book b2,
    loan l2
WHERE b2.authors = 'Adam Smith'
    AND l2.book = b2.isbn13
    AND l2.borrower = s2.email
) AS tmp;
-- Q3 = π(s2.email, s2.name, b2.isbn13)(p(loan, l2) ⋈ [l2.book = b2.isbn13 ∧ b2.authors = 'Adam Smith'] p(book, b2) ⋈ [l2.borrower = s2.email] p(student, s2))
-- Q4 = π[s2.email, s2.name](Q2 - Q3) 
-- Q5 = π[s3.email, s3.name](p(student, s3)) - Q4 --> Final solution