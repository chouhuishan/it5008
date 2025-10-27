/**
 * IT5008 Tutorial 01
 * Script adapted by Henry Heng
 */

-- create database if not exist
DROP DATABASE IF EXISTS "tut01";
CREATE DATABASE "tut01";

-- USE "tut01";

/**
 * For Question 1
 */

DROP TABLE IF EXISTS "loan";
DROP TABLE IF EXISTS "copy";
DROP TABLE IF EXISTS "student";
DROP TABLE IF EXISTS "book";

CREATE TABLE "book" (
  "title" VARCHAR(256) NOT NULL,
  "format" CHAR(9) CHECK("format" = 'paperback' OR "format" = 'hardcover'),
  "pages" INT,
  "language" VARCHAR(32),
  "authors" VARCHAR(256),
  "publisher" VARCHAR(64),
  "year" DATE,
  "ISBN10" CHAR(10) NOT NULL UNIQUE,
  "ISBN13" CHAR(14) PRIMARY KEY
);

CREATE TABLE "student" (
  "name" VARCHAR(32) NOT NULL,
  "email" VARCHAR(256) PRIMARY KEY,
  "year" DATE NOT NULL,
  "faculty" VARCHAR(62) NOT NULL,
  "department" VARCHAR(32) NOT NULL,
  "graduate" DATE, 

  CHECK("graduate" > "year")
);

-- Must fix bug: Create loan table first before copy

CREATE TABLE "copy" (
  "owner" VARCHAR(256)
    REFERENCES "student"("email") DEFERRABLE,
  "book" CHAR(14)
    REFERENCES "book"("ISBN13") DEFERRABLE,
  "copy" INT CHECK("copy" > 0),
  "available" VARCHAR(6) 
    CHECK("available" = 'TRUE' OR "available" = 'FALSE'),

  PRIMARY KEY ("owner", "book", "copy")
);

CREATE TABLE "loan" (
  "borrower" VARCHAR(256)
    REFERENCES "student"("email") DEFERRABLE,
  "owner" VARCHAR(256),
  "book" CHAR(14),
  "copy" INT,
  "borrowed" DATE,
  "returned" DATE,

  FOREIGN KEY ("owner", "book", "copy")
    REFERENCES "copy"("owner", "book", "copy") DEFERRABLE,
  PRIMARY KEY ("borrowed", "borrower", "owner", "book", "copy"),
  CHECK("returned" >= "borrowed")
);

/**
 * For Question 2
 * 
 * Note: Double quotes are for names of tables or fields.
 * Single quotes are for string constants.
 */

-- Question 2a
INSERT INTO "book" VALUES (
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

-- Question 2b - Same book, different ISBN13
-- ERROR:  duplicate key value violates unique constraint "book_ISBN10_key"
INSERT INTO "book" VALUES (
  'An Introduction to Database Systems', 
  'paperback', 
  640, 
  'English', 
  'C. J. Date', 
  'Pearson', 
  '2003-01-01', 
  '0321197844',     -- fails because ISBN10 is set to be unique
  '978-0201385908'  -- different ISBN13
);

-- Question 2c - Same book, different ISBN10
-- ERROR:  duplicate key value violates unique constraint "book_pkey"
INSERT INTO "book" VALUES (
  'An Introduction to Database Systems', 
  'paperback', 
  640, 
  'English', 
  'C. J. Date', 
  'Pearson', 
  '2003-01-01', 
  '0201385902',     -- different ISBN10
  '978-0321197849'  -- fails because ISBN13 is PK, need to be unique
);

-- Question 2d - Insert new record into "student"
INSERT INTO "student" VALUES (
  'TIKKI TAVI',
  'tikki@gmail.com',
  '2024-08-15',
  'School of Computing',
  'CS',
  NULL
);

-- Question 2e - Insert another new record into student, but specify columns
INSERT INTO "student" ("email", "name", "year", "faculty", "department") VALUES (
  'rikki@gmail.com',
  'RIKKI TAVI',
  '2024-08-15',
  'School of Computing',
  'CS'
);

-- Question 2f - Update department name from 'CS' to 'Computer Science'
UPDATE "student"
SET "department" = 'Computer Science'
WHERE "department" = 'CS';

-- Run script from NUNStAStudent.sql

-- Question 2g - Delete all students from 'chemistry' department
-- Nothing happens, since no students in 'chemistry' department
DELETE FROM "student"
WHERE "department" = 'chemistry';

-- Question 2h - Delete all students from 'Chemistry' department
-- Out of 105 students (use COUNT() function), 3 are from 'Chemistry' department.
-- Those 3 students are removed.
DELETE FROM "student"
WHERE "department" = 'Chemistry';

/** 
 * Question 3
 */

-- Question 3a: What does DEFERRABLE mean?
-- When a constraint is DEFERRED it is not validated until the transaction commits.

-- Question 3b
INSERT INTO "copy" VALUES (
  'tikki@gmail.com',
  '978-0321197849',
  1,
  'TRUE'
);

-- The following SQL script sets all constraints to be IMMEDIATE.
-- Running this script will result in an error.
-- ERROR:  update or delete on table "book" violates foreign key constraint "copy_book_fkey" on table "copy"
-- Key (ISBN13)=(978-0321197849) is still referenced from table "copy". 
BEGIN TRANSACTION;
  SET CONSTRAINTS ALL IMMEDIATE;
  DELETE FROM "book" WHERE "ISBN13" = '978-0321197849';
  DELETE FROM "copy" WHERE "book" = '978-0321197849';
END TRANSACTION;


-- The following SQL script sets all constraints to be DEFERRED.
-- Running this script will not result in an error.
BEGIN TRANSACTION;
  SET CONSTRAINTS ALL DEFERRED;
  DELETE FROM "book" WHERE "ISBN13" = '978-0321197849';
  DELETE FROM "copy" WHERE "book" = '978-0321197849';
END TRANSACTION;

/**
 * Question 4
 */

-- Question 4a
-- "available" column in "copy" table is not referenced anywhere - not currently useful
ALTER TABLE "copy" DROP COLUMN "available";

-- Question 4b
-- "department" and "faculty" describe granular information about student program.
-- Is this necessary?
-- 
-- Options:
-- A. "faculty" and "department" can be removed (no column dependencies) in favor of a single column "program".
-- B. Just remove "faculty".
ALTER TABLE "student" ADD COLUMN "program" VARCHAR(100);
UPDATE "student" SET "program" = "faculty" || ' - ' || "department";
ALTER TABLE "student" DROP COLUMN "faculty";
ALTER TABLE "student" DROP COLUMN "department";

-- C. Encapsulate "faculty" and "department" into a separate table (this will be used in demos going forward)
CREATE TABLE "department" (
  "department"  VARCHAR(32) PRIMARY KEY,
  "faculty" VARCHAR(62) NOT NULL
);
INSERT INTO "department"
  SELECT DISTINCT "department", "faculty"
  FROM "student";

ALTER TABLE "student" DROP COLUMN "faculty";

ALTER TABLE "student"
ADD FOREIGN KEY ("department")
  REFERENCES "department"("department");

