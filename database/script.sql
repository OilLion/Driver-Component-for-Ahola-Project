DROP TABLE DRIVER;

CREATE TABLE IF NOT EXISTS DRIVER (
    id SERIAL                 PRIMARY KEY,
    name varchar(255)         NOT NULL,
    password varchar(255)     NOT NULL,
    logged_in bool            DEFAULT false,
    available bool            DEFAULT false
);

ALTER TABLE DRIVER ADD CONSTRAINT constraint_name UNIQUE (name);
