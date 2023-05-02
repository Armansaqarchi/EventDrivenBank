-- a procedure which simply takes parameters and create a transaction
CREATE OR REPLACE PROCEDURE create_transaction(type STATUS, from BIGINT, to BIGINT, amount BIGINT)
LANGUAGE plpgsql
AS $$
    BEGIN
        INSERT INTO transactions(type, from, to, amount) VALUES (type, from, to, amount);
    END;
$$;