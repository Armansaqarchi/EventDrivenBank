import sys
import settings
import time

from start import logger
from psycopg2.extensions import connection
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
            num = 1
            
            for arg in args[0]:
                print(str(num) + f"-{arg}")
                num += 1
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

        if choice == 1:
            username = input("enter username")
            password = input("enter password")
            cursor = AppInput.conn.cursor()
            cursor.callproc("LOGIN", [username, password])
            logged_in = cursor.fetchone()[0]

            if(logged_in):
                print("successfully logged in")
                self.main_menu()
        elif choice == 2:
            #accountNumber NUMERIC(16, 0), password VARCHAR(60),
#firstname VARCHAR(60), lastname VARCHAR(60), nationalID NUMERIC(10, 0), birth_of_date DATE, type USER_STATUS, interest_rate INT
            print("enter the following informations :")
            account_number = input("Account number :")
            password = input("password")
            firstname = input("firstname")
            lastname = input("lastname")
            nationalID = input("nationalID")
            birth_of_date = input("birth_of_date(in format yyyy-mm-dd)")

            print("choose type of user")
            type = self.get_input((("client", "employee")))

            interest_rate = 0.05
            if not self._check_date_valids(birth_of_date):
                cursor.callproc("REGISTER", [account_number, password, firstname, lastname, nationalID, birth_of_date, type, interest_rate])
                res = cursor.fetchone()[0]
                if res == True:
                    time.sleep(0.3)
                    cursor.execute("SELECT username FROM accounts where accountNumber = %s" %(account_number))
                    username = cursor.fetchone()[0]
                    print(f"registeration successfully done, here is you username : {username}")
                else:
                    print("something went wrong while registering the user")    
            else:
                print("invalid information")
        elif choice == 3:

    
    def _check_date_valids(birth_of_date):
        try:
            numbers = birth_of_date.split("-")
            year = numbers[0]
            month = numbers[1]
            day = numbers[2]
        except ValueError:
            return False

        return  True



class InvalidChoiceException(Exception):
    pass