CREATE TYPE STATUS AS ENUM ('CLIENT', 'EMPLOYEE');


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

CREATE SEQUENCE IF NOT EXISTS NUMBER
START 1
INCREMENT 1
NO MAXVALUE;


CREATE OR REPLACE FUNCTION make_username ()
    RETURNS TRIGGER AS $$
        BEGIN
            UPDATE account SET username = NEW.firstname || '-' || NEW.lastname || '-',  nextval('number') ;
        END
    $$ LANGUAGE plpgsql;


CREATE TRIGGER username AFTER INSERT ON account FOR EACH ROW
    EXECUTE FUNCTION make_username();

CREATE OR REPLACE PROCEDURE register(accountNumber NUMERIC(16, 0), password VARCHAR(60),
firstname VARCHAR(60), lastname VARCHAR(60), nationalID NUMERIC(10, 0), birth_of_date DATE, type STATUS, interest_rate INT)
AS $$
    DECLARE hashed_password VARCHAR(60);
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_of_date) > 13 THEN
            SET hashed_password = encode(DIGEST(password, 'sha256'), 'hex');
            INSERT INTO account(accountNumber, password, firstname, lastname, nationalID, birth_of_date, interest_rate)
            VALUES(accountNumber, hashed_password, firstname, lastname, nationalID, birth_of_date, interest_rate);
            RETURN 'user successfully created, username : ' || username
        END IF;
    END;
$$ LANGUAGE plpgsql 

