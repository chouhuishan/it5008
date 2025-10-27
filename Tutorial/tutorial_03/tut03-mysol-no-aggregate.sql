/**
 * IT5008 Tutorial 03 (without aggregates)
 * Script authored/adapted by Henry Heng
 */

DROP TABLE IF EXISTS taste;
DROP TABLE IF EXISTS bottle;
DROP TABLE IF EXISTS wine;
DROP TABLE IF EXISTS member;

CREATE TABLE member (
  card_no CHAR(10) PRIMARY KEY,
  first_name VARCHAR(128) NOT NULL,
  last_name VARCHAR(128) NOT NULL,
  email VARCHAR(256) NOT NULL         -- contacct address (allow physical address?)
);


CREATE TABLE wine (
  name VARCHAR(64) NOT NULL,
  appellation VARCHAR(64) NOT NULL,
  vintage DATE NOT NULL,
  alcoholic_degree NUMERIC NOT NULL,
  bottled VARCHAR(256) NOT NULL,      -- "...where and by whom it has been bottled..."
  certification VARCHAR(32),          -- "...certification of its appellation if available..."
  country VARCHAR(64) NOT NULL,

  -- "Each wine is identified by its name, appellation, and vintage."
  PRIMARY KEY (name, appellation, vintage)
);

CREATE TABLE bottle (
  -- from "wine" table
  wine_name VARCHAR(64) NOT NULL,
  appellation VARCHAR(64) NOT NULL,
  vintage DATE NOT NULL,
  
  -- own attribute(s)
  number INTEGER CHECK (number > 0),

  -- NOTE: You can state FK first before PK (just tested, it worked)
  --       But.. you may wanna conform to how it's usually presented instead.
  PRIMARY KEY (number, wine_name, appellation, vintage),
  FOREIGN KEY (wine_name, appellation, vintage)
    REFERENCES wine (name, appellation, vintage)
);

-- "taste" Relationship
CREATE TABLE taste (
  -- from "bottle" table
  wine_name VARCHAR(64) NOT NULL,
  appellation VARCHAR(64) NOT NULL,
  vintage DATE NOT NULL,
  bottle_no INTEGER NOT NULL,

  -- from "member" table
  member CHAR(10) NOT NULL
    REFERENCES member (card_no),

  -- own attribute(s)
  tasting_date DATE NOT NULL DEFAULT CURRENT_DATE,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 10), -- I prefer this way, allow for app interface to decipher what this means

  PRIMARY KEY (member, bottle_no, wine_name, appellation, vintage),
  FOREIGN KEY (bottle_no, wine_name, appellation, vintage)
    REFERENCES bottle (number, wine_name, appellation, vintage)
);


