-- Q2a Without Aggregate
CREATE TABLE member (
  card_number  CHAR(10)     PRIMARY KEY,
  address      VARCHAR(64)  NOT NULL,
  name         VARCHAR(32)  NOT NULL
);

CREATE TABLE wine (
  name            VARCHAR(32),
  appellation     VARCHAR(32),
  vintage         DATE,
  alcohol_degree  NUMERIC NOT NULL,
  bottled         VARCHAR(128) NOT NULL,
  certification   VARCHAR(64),
  country         VARCHAR(32) NOT NULL,
  PRIMARY KEY (name, appellation, vintage)
);

CREATE TABLE bottle (
  wine_name       VARCHAR(32),
  appellation     VARCHAR(32),
  vintage         DATE,
  number          INTEGER CHECK (number > 0),
  PRIMARY KEY (number, wine_name, appellation, vintage),
  FOREIGN KEY (wine_name, appellation, vintage)
    REFERENCES wine (name, appellation, vintage)
);

CREATE TABLE taste (
  wine_name      VARCHAR(32),
  appellation    VARCHAR(32),
  vintage        DATE,
  bottle_number  INTEGER,
  member         CHAR(10)
    REFERENCES member (card_number),
  tasting_date   DATE NOT NULL,
  rating         VARCHAR(32) NOT NULL,
  PRIMARY KEY (member, bottle_number, wine_name, appellation, vintage),
  FOREIGN KEY (bottle_number, wine_name, appellation, vintage)
    REFERENCES bottle (bottle_number, wine_name, appellation, vintage)
);


-- Q2a With Aggregate
CREATE TABLE member (
  card_number  CHAR(10)     PRIMARY KEY,
  address      VARCHAR(64)  NOT NULL,
  name         VARCHAR(32)  NOT NULL
);

CREATE TABLE wine (
  name            VARCHAR(32),
  appellation     VARCHAR(32),
  vintage         DATE,
  alcohol_degree  NUMERIC NOT NULL,
  bottled         VARCHAR(128) NOT NULL,
  certification   VARCHAR(64),
  country         VARCHAR(32) NOT NULL,
  PRIMARY KEY (name, appellation, vintage)
);

CREATE TABLE session (
  year  INTEGER,
  week  INTEGER,
  PRIMARY KEY (year, week)
);

CREATE TABLE bottle (
  wine_name       VARCHAR(32),
  appellation     VARCHAR(32),
  vintage         DATE,
  number          INTEGER CHECK (number > 0),
  PRIMARY KEY (number, wine_name, appellation, vintage),
  FOREIGN KEY (wine_name, appellation, vintage)
    REFERENCES wine (name, appellation, vintage)
);

CREATE TABLE open (
  wine_name       VARCHAR(32),
  appellation     VARCHAR(32),
  vintage         DATE,
  bottle_number   INTEGER,
  session_year    INTEGER NOT NULL,
  session_week    INTEGER NOT NULL,
  PRIMARY KEY (bottle_number, wine_name, appellation, vintage),
  FOREIGN KEY (session_year, session_week)
    REFERENCES session (year, week),
  FOREIGN KEY (bottle_number, wine_name, appellation, vintage)
    REFERENCES bottle (number, wine_name, appellation, vintage)
);

CREATE TABLE taste (
  wine_name      VARCHAR(32),
  appellation    VARCHAR(32),
  vintage        DATE,
  bottle_number  INTEGER,
  member         CHAR(10)
    REFERENCES member (card_number),
  rating         VARCHAR(32) NOT NULL,
  PRIMARY KEY (member, bottle_number, wine_name, appellation, vintage),
  FOREIGN KEY (bottle_number, wine_name, appellation, vintage)
    REFERENCES open (bottle_number, wine_name, appellation, vintage)
);


