
CREATE TYPE STATUS AS ENUM ('deposit', 'withdraw', 'transfer', 'interest');

----------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS transactions(
    type STATUS,
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "from" BIGINT REFERENCES account(accountNumber),
    "to" BIGINT REFERENCES account(accountNumber),
    amount BIGINT
)