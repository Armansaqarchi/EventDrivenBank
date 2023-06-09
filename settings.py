from os import path
from pathlib import Path


# database configuration


# project directory
BASE_DIR = Path(__file__).resolve().parent



db = {
    "HOST" : "127.0.0.1",
    "DATABASE" : "postgres",
    "PORT" : "5432",
    "USER" : "mahan",
    "PASSWORD" : "test123123"
}



LOGGING = {
    "level" : "INFO"
}

CRONTAB = {
    "commands" : {
        path.join(BASE_DIR, "commands", "updates_balances.py")
    },
    # this means that the job is triggered every minute
    "schedule" : "* * * * *"
}


DDL_PATH = {
    "tables" : path.join(BASE_DIR, "db/tables"),
    "procedures" : path.join(BASE_DIR, "db/procedures")}

MAIN_MENU = ('withdraw', 'transfer', 'deposit', 'check_balance', 'exit')


MAIN_MENU__EMPLOYEE = ('withdraw', 'transfer', 'deposit', 'check_balance', 'update balance', 'exit')


LOGIN_MENU = ('login', 'register', "quit")

INTEREST_RATE = 0.05