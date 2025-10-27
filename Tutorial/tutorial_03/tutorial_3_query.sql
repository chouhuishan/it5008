CREATE TABLE member (
    id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name VARCHAR(128) NOT NULL
);
CREATE TABLE wine (
    name VARCHAR(64) NOT NULL,
    appellation VARCHAR(64) NOT NULL,
    vintage DATE NOT NULL,
    alcoholic_degree NUMERIC NOT NULL,
    bottled VARCHAR(128) NOT NULL,
    certification VARCHAR(32),
    PRIMARY KEY (name, appellation, vintage)
);
CREATE TABLE bottle (
    number INTEGER CHECK (number > 0),
    -- from 'wine' table
    wine_name VARCHAR(64) NOT NULL,
    appellation VARCHAR(64) NOT NULL,
    vintage DATE NOT NULL,
    PRIMARY KEY (number, wine_name, appellation, vintage) FOREIGN KEY (wine_name, appellation, vintage) REFERENCES wine (name, appellation, vintage)
);
CREATE TABLE taste (
    tasting_date DATE NOT NULL DEFAULT CURRENT_DATE,
    rating INT NOT NULL CHECK (
        rating >= 1
        AND rating <= 10
    ),
    -- from 'member' table 
    member_id VARCHAR(10) PRIMARY KEY NOT NULL,
    -- from 'bottle' table
    bottle_no INTEGER CHECK (number > 0),
    wine_name VARCHAR(64) NOT NULL,
    appellation VARCHAR(64) NOT NULL,
    vintage DATE NOT NULL,
    PRIMARY KEY (
        member_id,
        bottle_no,
        wine_name,
        appellation,
        vintage
    ),
    FOREIGN KEY (member_id),
    REFERENCES member(id),
    FOREIGN KEY (bottle_no, wine_name, appellation, vintage) REFERENCES bottle(number, wine_name, appellation, vintage)
);