-- Q2a INSERT INTO
INSERT INTO book VALUES (
  'An Introduction to Database Systems',
  'paperback',
  640,
  'English',
  'C. J. Date',
  'Pearson',
  '2003-01-01',
  '0321197844',
  '978-0321197849'
);


-- Q2d INSERT INTO
INSERT INTO student VALUES (
  'TIKKI TAVI',
  'tikki@gmail.com',
  '2024-08-15',
  'School of Computing',
  'CS',
  NULL
);


-- Q2e INSERT INTO
INSERT INTO student (email, name, year, faculty, department) VALUES (
  'rikki@gmail.com',
  'RIKKI TAVI',
  '2024-08-15',
  'School of Computing',
  'CS'
);


-- Q2f UPDATE
UPDATE student
SET department = 'Computer Science'
WHERE department = 'CS';


-- Q3b INSERT INTO
INSERT INTO copy VALUES (
  'tikki@gmail.com',
  '978-0321197849',
  1,
  'TRUE'
);


-- Q3b Transaction 1
BEGIN TRANSACTION;
  SET CONSTRAINTS ALL IMMEDIATE;
  DELETE FROM book WHERE ISBN13 = '978-0321197849';
  DELETE FROM copy WHERE book = '978-0321197849';
END TRANSACTION;


-- Q3b Transaction 2
BEGIN TRANSACTION;
  SET CONSTRAINTS ALL DEFERRED;
  DELETE FROM book WHERE ISBN13 = '978-0321197849';
  DELETE FROM copy WHERE book = '978-0321197849';
END TRANSACTION;


