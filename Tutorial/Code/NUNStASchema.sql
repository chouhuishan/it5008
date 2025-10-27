/*******************
 
 Create the schema.
 
 ********************/
-- CREATE SCHEMA IF NOT EXISTS book_exchange;
-- SET search_path TO book_exchange;
CREATE TABLE IF NOT EXISTS book (
  title VARCHAR(256) NOT NULL,
  format CHAR(9) CONSTRAINT format CHECK(
    format = 'paperback'
    OR format = 'hardcover'
  ),
  pages INT,
  language VARCHAR(32),
  authors VARCHAR(256),
  publisher VARCHAR(64),
  year DATE,
  ISBN10 CHAR(10) NOT NULL UNIQUE,
  ISBN13 CHAR(14) PRIMARY KEY
);
CREATE TABLE IF NOT EXISTS student (
  name VARCHAR(32) NOT NULL,
  email VARCHAR(256) PRIMARY KEY,
  year DATE NOT NULL,
  faculty VARCHAR(62) NOT NULL,
  department VARCHAR(32) NOT NULL,
  graduate DATE,
  CHECK(graduate >= year)
);
CREATE TABLE IF NOT EXISTS copy (
  owner VARCHAR(256) REFERENCES student(email) DEFERRABLE,
  book CHAR(14) REFERENCES book(ISBN13) DEFERRABLE,
  copy INT CHECK(copy > 0),
  available VARCHAR(6) CHECK(
    available = 'TRUE'
    OR available = 'FALSE'
  ),
  PRIMARY KEY (owner, book, copy)
);
CREATE TABLE IF NOT EXISTS loan (
  borrower VARCHAR(256) REFERENCES student(email) DEFERRABLE,
  owner VARCHAR(256),
  book CHAR(14),
  copy INT,
  borrowed DATE,
  returned DATE,
  FOREIGN KEY (owner, book, copy) REFERENCES copy(owner, book, copy) DEFERRABLE,
  PRIMARY KEY (borrowed, borrower, owner, book, copy),
  CHECK(returned >= borrowed)
);