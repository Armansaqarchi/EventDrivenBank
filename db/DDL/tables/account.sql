CREATE TYPE STATUS AS ENUM ('CLIENT', 'EMPLOYEE');

-----------------------------------------------------

CREATE TABLE IF NOT EXISTS account(
    username VARCHAR(60) UNIQUE,
    accountNumber NUMERIC(16, 0),
    password VARCHAR(200),
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    nationalID NUMERIC(10, 0),
    birth_of_date DATE,
    type STATUS,
    interest_rate INT NOT NULL
);

-------------------------------------------------------


CREATE SEQUENCE IF NOT EXISTS NUMBER
START 1
INCREMENT 1
NO MAXVALUE;


--------------------------------------------------------

CREATE OR REPLACE FUNCTION make_username ()
    RETURNS TRIGGER AS $$
        BEGIN
            UPDATE account SET username = NEW.firstname || '-' || NEW.lastname || '-',  nextval('number') ;
        END
    $$ LANGUAGE plpgsql;


CREATE TRIGGER username AFTER INSERT ON account FOR EACH ROW
    EXECUTE FUNCTION make_username();

