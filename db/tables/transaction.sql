CREATE TYPE public.status AS ENUM
    ('deposit', 'withdraw', 'transfer', 'interest');

----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.transactions
(
    type status,
    transaction_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    from_account bigint,
    to_account bigint,
    amount bigint,
    CONSTRAINT transactions_from_fkey FOREIGN KEY (from_account)
        REFERENCES public.account (accountnumber) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT transactions_to_fkey FOREIGN KEY (to_account)
        REFERENCES public.account (accountnumber) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)