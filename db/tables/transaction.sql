
CREATE TYPE STATUS IF NOT EXISTS AS ENUM ('deposit', 'withdraw', 'transfer', 'interest');

----------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS transactions(
    type STATUS,
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    form BIGINT FOREIGN KEY REFERENCES account(accountNumber),
    to BIGINT FOREIGN KEY REFERENCES account(accountNumber)
    amount BIGINT
)