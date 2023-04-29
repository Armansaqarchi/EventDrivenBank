from os import path
from pathlib import Path


# database configuration


# project directory
BASE_DIR = Path(__file__).resolve().parent


db = {
    "HOST" : "127.0.0.1",
    "DATABASE" : "event_driven",
    "PORT" : "5432",
    "USER" : "mahan",
    "PASSWORD" : "test123123"
}



LOGGING = {
    "level" : "logging.INFO"
}

CRONTAB = {
    "commands" : {
        path.join(BASE_DIR, "commands", "updates_balances.py")
    },
    # this means that the job is triggered every minute
    "schedule" : "* * * * *"
}


DDL_PATH = path.join(BASE_DIR, "core/DDL")

MAIN_MENU = ('withdraw', 'transfer', 'deposit', 'interest_payment', 'exit')

LOGIN_MENU = ('login', 'register', "quit")

INTEREST_RATE = 0.05