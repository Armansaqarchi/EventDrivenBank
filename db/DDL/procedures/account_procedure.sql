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

