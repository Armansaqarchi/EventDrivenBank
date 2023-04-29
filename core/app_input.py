import sys
import settings

from start import logger
from psycopg2 import connection
from psycopg2 import(
    ProgrammingError
)


class AppInput:

    conn = None

    def __init__(self, connection : connection) -> None:
        self.logger = logger
        conn = connection



    def get_input(self, *args) -> int:
        """
        takes a tuple of options and shows them in the console
        this function also encapsulates the input data to be a correct choice
        """
        while True:
            # number of choice
            num = int()
            for arg in args:
                print(num + f"-{arg}")
            try:
                choice = int(input())
                # number of choices available
                num_of_choices = sys.getsizeof(args)
                # validity of choice
                if choice > num_of_choices or choice < 1:
                    raise InvalidChoiceException()
            except (InvalidChoiceException or ValueError) as e:
                message = f"the choice must be a number from 1 to {num_of_choices}"
                print(message)    
            else:
                return choice
    

    def main_menu(self, *args) -> int:
        """
        invokes input function and performs main operations
        """
        while(True):
            try:
                choice = self.get_input(settings.MAIN_MENU)

                if choice == 1:
                    # perform withdraw
                    amount = input("enter the amount of funds you would like to withdraw")
                    logger.info("preparing for withdraw transaction")

                    cursor= AppInput.conn.cursor()
                    cursor.execute("SELECT * FROM make_transaction(%s, %s, %s)" %(amount, 'withdraw', None))
                    print(cursor.fetchone()[0])

                
                elif choice == 2:
                    # perform transfer
                    amount = input("enter the amount of funds you would like to transfer")
                    logger.info("preparing for transfer transaction")
                    account_number =  input("which account number you would like to transfer to?")

                    if len(account_number) != 16 :
                        print("invalid account number, the number must be a combination of 16 characters")
                        continue

                    cursor = AppInput.conn.cursor()
                    cursor.execute("SELECT * FROM make_transaction(%s, %s, %s)" %(amount, 'transfer', account_number))
                    print(cursor.fetchone()[0])

                elif choice == 3:
                    amount = input("amount of money to deposit?")
                    cursor = AppInput.conn.cursor()
                    cursor.execute("SELECT * FROM make_transaction(%s, %s, %s)" %(amount, 'deposit'))
                    print(cursor.fetchone()[0])
                    cursor.close()
                elif choice == 4:
                    sys.exit(0)
                    

            except ProgrammingError as e:
                logger.error("failed to fire the function or database may have been improperly configured")
        

    
    def login_menu(self, *args) -> int:
        """
        invokes input function and performs login operations
        """
        choice = self.get_input(settings.LOGIN_MENU)

    
            




class InvalidChoiceException(Exception):
    pass