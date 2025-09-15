-- L1 : Creating and Populating Tables with Constraints
/*******************
 
 Original schema as per AppStoreSchema.sql
 
 ********************/
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
-- new customer can be added to the table even if the customer has not downloaded any games
-- do not have to introduce NULL values
CREATE TABLE IF NOT EXISTS app_store.customers (
    -- Customer ORIGINAL TABLE 1
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    email VARCHAR(64),
    dob DATE,
    since DATE,
    customerid VARCHAR(16),
    -- applies to the row
    country VARCHAR(16)
);
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
-- This table differs from orignal, NOTE : PRIMARY KEY to customerid
CREATE TABLE IF NOT EXISTS app_store.customers (
    -- Customer TABLE 2
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    email VARCHAR(64),
    dob DATE,
    since DATE,
    customerid VARCHAR(16) PRIMARY KEY,
    -- applies to the row
    country VARCHAR(16)
);
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
SET search_path TO app_store;
INSERT INTO customers
VALUES (
        'Carole',
        'Yoga',
        'cyoga@glarge.org',
        '2002-08-01',
        '2024-08-09',
        'Carole89',
        'France'
    )
SET search_path TO app_store;
INSERT INTO customers
VALUES (
        'Carole',
        'Yoga',
        'cyoga@glarge.org',
        '2002-08-01',
        '2024-08-09',
        'Carole89',
        'France'
    ) --> double insertion leads to an error, due to duplicated customerid that is the primary key
    -- This table varies from the one above; NOTE: HOW PRIMARY KEY AFFECTS
    CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.customers (
    -- Customer TABLE 3
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    email VARCHAR(64),
    dob DATE,
    since DATE,
    customerid VARCHAR(16),
    country VARCHAR(16),
    PRIMARY KEY (customerid) -- after row
);
-- This table varies from the original, NOTE: UNIQUE at email
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.customers (
    -- Customer TABLE 4
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    email VARCHAR(64) UNIQUE,
    dob DATE,
    since DATE,
    customerid VARCHAR(16),
    country VARCHAR(16),
    UNIQUE (first_name, last_name)
);
-- rather than using a single table by splitting the table, we need to remember 
-- the identifier of the customers (customerid) and games (name, version)
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.games(
    -- Games ORIGINAL TABLE 1
    name VARCHAR(32),
    version CHAR(3),
    price NUMERIC
);
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
-- This table is varies from the original, NOTE: PRIMARY KEY
CREATE TABLE IF NOT EXISTS app_store.games(
    -- Games TABLE 2
    name VARCHAR(32),
    version CHAR(3),
    price NUMERIC,
    PRIMARY KEY (name, version) -- this is a composite primary key (table constraint)
);
SET search_path TO app_store;
INSERT INTO games
VALUES ('Aerified', '1.0', 5),
    ('Aerified', '1.0', 6);
--> INSERTION FAIL; duplicate key value which is the primary key (name, version)
SET search_path TO app_store;
INSERT INTO games
VALUES ('Aerified', '1.0', 5),
    ('Aerified', '2.0', 6),
    ('Verified', '1.0', 7) --> INSERTION SUCCESS, as the version is different, allowing the primary key to be unique, despite having the same name
    -- this table varies from the one above, because of the additionl of column constraints, NOT NULL under price
    CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.games(
    -- Games TABLE 3
    name VARCHAR(32),
    version CHAR(3),
    price NUMERIC NOT NULL,
    PRIMARY KEY (name, version)
);
SET search_path TO app_store;
INSERT INTO games (name, version)
VALUES ('Aerified2', '1.0');
--> INSERTION FAIL : Price is not stated, leading to an implicit null, but price cannot be null as per schema above
SET search_path TO app_store;
INSERT INTO games (name, version)
VALUES ('Aerified2', '1.0', NULL);
--> INSERTION FAIL
-- This table varies from the one above, NOTE: Addition of DEFAULT 1.00
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.games(
    -- Games TABLE 4
    name VARCHAR(32),
    version CHAR(3),
    price NUMERIC NOT NULL DEFAULT 1.00,
    PRIMARY KEY (name, version)
);
SET search_path TO app_store;
INSERT INTO games (name, version)
VALUES ('Aerified2', '1.0');
--> INSERTION SUCCESS, despite price not stated, price will be defaulted to 1.00
SET search_path TO app_store;
INSERT INTO games (name, version)
VALUES ('Aerified2', '1.0', NULL);
-- This table varies from original, NOTE: CHECK constraint added to check price > 0
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.games(
    -- Games TABLE 5
    name VARCHAR(32),
    version CHAR(3),
    price NUMERIC NOT NULL CHECK (price > 0),
    PRIMARY KEY (name, version)
);
UPDATE app_store.games
SET price = price - 5.5;
-- UPDATE FAIL : Price cannot be negative
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.downloads(
    -- Downloads ORIGNIAL TABLE 1
    customerid VARCHAR(16),
    name VARCHAR(32),
    version CHAR(3)
);
-- This table varies from the original: NOTE: Introduction of FOREIGN KEY
-- REFERENCES TO customer TABLE 2 & games TABLE 2
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.downloads (
    -- Downloads TABLE 2
    customerid VARCHAR(16) REFERENCES app_store.customers (customerid),
    name VARCHAR(32),
    version CHAR(3),
    FOREIGN KEY (name, version) REFERENCES app_store.games (name, version)
);
SET search_path TO app_store;
INSERT INTO downloads
VALUES ('Adam1983', 'Aerified2', '1.0');
-- INSERTION FAIL, no matching row in app_store.games with this pair ('Aerified2', '1.0')
SET search_path TO app_store;
INSERT INTO downloads
VALUES ('Carole89', 'Aerified', '1.1');
-- INSERTION FAIL, no matching row in app_store.games with this pair ('Aerified', '1.0')
SET search_path TO app_store;
INSERT INTO downloads
VALUES (NULL, 'Aerified', '1.0');
-- INSERTION FAIL, no matching row in app_store.games with this pair ('Aerified2', '1.0')
SET search_path TO app_store;
INSERT INTO downloads
VALUES ('Carole89', NULL, '1.1');
-- INSERTION FAIL, no matching row in app_store.games with this pair ('Aerified', '1.0')
-- This table is different from above, NOTE: Usage of CASCADE
CREATE SCHEMA IF NOT EXISTS app_store;
SET search_path TO app_store;
CREATE TABLE IF NOT EXISTS app_store.downloads (
    -- Downloads TABLE 3
    customerid VARCHAR(16) REFERENCES app_store.customers (customerid) ON UPDATE CASCADE ON DELETE CASCADE,
    name VARCHAR(32),
    version CHAR(3),
    FOREIGN KEY (name, version) REFERENCES app_store.games (name, version) ON UPDATE CASCADE ON DELETE CASCADE
);
-- PRIMARY KEY : Set of columns that uniquely identifies a record in the table. 
--               Each table has at most 1 primary key.
--               Can be one comlumn or combinanation of column.
-- NOT NULL (Games TABLE 3) : Constraint - NOT NULL ensures that no value under price can be set to NULL
-- DEFAULT (Games TABLE 4) : Ensures that value will be automatically put to 1.00 if price is not given
-- UNIQUE : Ensures that the table cannot contain two records with the same email
-- REFERENCES : Referenced column needs to be referred to PRIMARY KEY (column constraint)
-- CHECK : Arbitary check
-- CASCADE : Propogate the update/delete with chain reaction (E.g. if customerid is changed, it will be changed for everywhere else)