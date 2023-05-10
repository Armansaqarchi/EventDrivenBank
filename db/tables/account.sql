
CREATE TYPE USER_STATUS AS ENUM ('CLIENT', 'EMPLOYEE');

-----------------------------------------------------

CREATE TABLE IF NOT EXISTS account(
    username VARCHAR(60) UNIQUE,
    accountNumber NUMERIC(16, 0) UNIQUE,
    password VARCHAR(200),
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    nationalID NUMERIC(10, 0),
    birth_of_date DATE,
    type USER_STATUS,
    interest_rate INT NOT NULL
);

-------------------------------------------------------


CREATE SEQUENCE IF NOT EXISTS NUMBER
START 1
INCREMENT 1
NO MAXVALUE;


--------------------------------------------------------

CREATE OR REPLACE FUNCTION make_username()
    RETURNS TRIGGER AS $$
        DECLARE id VARCHAR(50);
        BEGIN
            id := nextval('number');
            UPDATE account SET username = NEW.firstname || '-' || NEW.lastname || '-' || id;
            RETURN NEW;
        END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------

CREATE OR REPLACE TRIGGER username AFTER INSERT ON account FOR EACH ROW
    EXECUTE FUNCTION make_username();

