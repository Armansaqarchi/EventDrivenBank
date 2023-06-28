import enum

class AnonymousUser:
    pass

class Type(enum.Enum):
    CLIENT = 'client'
    EMPLOYEE = 'employee'

class User(AnonymousUser):

    def __init__(self, username : str, account_number : str, type : Type) -> None:
        self.username = username
        self.account_number = account_number
        self.type = type
