
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE public.user_status AS ENUM
    ('CLIENT', 'EMPLOYEE');

-----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.account
(
    username character varying(120) COLLATE pg_catalog."default",
    accountnumber numeric(16,0),
    password character varying(500) COLLATE pg_catalog."default",
    firstname character varying(50) COLLATE pg_catalog."default",
    lastname character varying(50) COLLATE pg_catalog."default",
    nationalid numeric(10,0),
    birth_of_date date,
    type user_status,
    interest_rate double precision NOT NULL,
    CONSTRAINT account_accountnumber_key UNIQUE (accountnumber),
    CONSTRAINT account_username_key UNIQUE (username)
);

-------------------------------------------------------


CREATE SEQUENCE IF NOT EXISTS public."number"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;


--------------------------------------------------------
CREATE OR REPLACE FUNCTION public.make_username()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
        DECLARE id VARCHAR(50);
        BEGIN
            id := nextval('number');
            UPDATE account SET username = NEW.firstname || '-' || NEW.lastname || '-' || id WHERE accountNumber = NEW.accountNumber;
            RETURN NEW;
        END;
$BODY$;

--------------------------------------------------------

CREATE OR REPLACE TRIGGER username AFTER INSERT ON account FOR EACH ROW
    EXECUTE FUNCTION make_username();

