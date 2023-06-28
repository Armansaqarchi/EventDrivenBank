import sys
import settings
import time

from start import logger
from psycopg2.extensions import connection
from .user import User
from psycopg2 import(
    ProgrammingError
)


class AppInput:

    conn = None
    user = None

    def __init__(self) -> None:
        self.logger = logger
        
        



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
            except InvalidChoiceException as e:
                message = f"the choice must be a number from 1 to {num_of_choices}"
                print(message)
            except ValueError as e:
                message = f"the choice must be an integer"
                print(message)
            else:
                return choice
    

    def main_menu(self, *args) -> int:
        """
        invokes input function and performs main operations
        """
        while(True):
            try:
                choice = self.get_input(settings.MAIN_MENU if self.user.type == "CLIENT" else settings.MAIN_MENU__EMPLOYEE)

                if choice == 1:
                    # perform withdraw
                    amount = input("enter the amount of funds you would like to withdraw : ")
                    logger.info("preparing for withdraw transaction")

                    cursor= AppInput.conn.cursor()
                    cursor.execute("CALL make_transaction(%s::numeric, %s::status, %s::numeric, %s::varchar)", [amount, 'withdraw', None, None])
                    print(cursor.fetchone()[0])
                    

                
                elif choice == 2:
                    # perform transfer
                    amount = input("enter the amount of funds you would like to transfer")
                    account_number =  input("which account number you would like to transfer to?")

                    # if len(account_number) != 16 :
                    #     print("invalid account number, the number must be a combination of 16 characters")
                    #     continue

                    cursor = AppInput.conn.cursor()
                    cursor.execute("CALL make_transaction(%s::numeric, %s::status, %s::numeric, %s::varchar)", [amount, 'transfer', account_number, None])
                    print(cursor.fetchone()[0])
                    

                elif choice == 3:
                    # perform deposit
                    amount = input("amount of money to deposit?")
                    cursor = AppInput.conn.cursor()
                    cursor.execute("CALL make_transaction(%s::numeric, %s::status, %s::numeric, %s::varchar)", [amount, 'deposit', None, None])
                    print(cursor.fetchone()[0])
                    
                    cursor.close()
                elif choice == 4:
                    #perform check_balance
                    cursor = AppInput.conn.cursor()
                    cursor.execute("CALL check_balance(%s::integer)", [None])
                    print(f"you have total of {cursor.fetchone()[0]} in your bank account")
                    
                elif choice == 5:
                    if self.user.type == "CLIENT":
                        AppInput.conn.close()
                        sys.exit(0)
                    else:
                        cursor = AppInput.conn.cursor()
                        cursor.execute("CALL update_balance(%s::boolean)", [None])
                        print("successfully updated")

                elif choice == 6 and self.user.type == "EMPLOYEE":
                     sys.exit(0)

                AppInput.conn.commit()
            except Exception:
                print('failed to make the transaction')
        

    
    def login_menu(self, *args) -> int:
        """
        invokes input function and performs login operations
        """
        choice = self.get_input(settings.LOGIN_MENU)

        if choice == 1:
            username = input("enter username: ")
            password = input("enter password: ")
            cursor = AppInput.conn.cursor()

            cursor.execute("CALL login(%s, %s, %s)", [username, password, None])

            res = cursor.fetchone()[0]
            print(res)


            if res.split(",")[0] == "True":
                print("successfully logged in")
                cursor.execute("SELECT username, type FROM account where username = %s", [username])
                res = cursor.fetchone()
                self.user = User(type = res[1], username=res[0])
                self.main_menu()

            print("invalid username or password")


        elif choice == 2:

            print("enter the following informations :")
            account_number = input("Account number :")
            password = input("password : ")
            firstname = input("firstname : ")
            lastname = input("lastname : ")
            nationalID = input("nationalID : ")
            birth_of_date = input("birth_of_date(in format yyyy-mm-dd) : ")


            if len(account_number) != 16:
                return

            print("choose type of user")
            type = self.get_input((("client", "employee")))

            interest_rate = 0.05
            if self._check_date_valids(birth_of_date):
                cursor = AppInput.conn.cursor()
                
                
                cursor.execute("CALL register(%s::numeric, %s::varchar, %s::varchar, %s::varchar, %s::numeric, %s::date, %s::user_status, %s::float, %s::varchar);", 
                                                                [account_number, password, firstname,
                                                                lastname, nationalID, birth_of_date, str('CLIENT' if type == 1 else 'EMPLOYEE'), interest_rate, None])
                
                res = cursor.fetchone()[0]
                print(res)
                
                if res.split(",")[0] == 'True':
                    time.sleep(0.3)
                    AppInput.conn.commit()
                    cursor.execute("SELECT username, type FROM account where accountNumber = %s" %(account_number))
                    res = cursor.fetchone()
                    username = res[0]
                    type = res[1]
                    print(f"registeration successfully done, here is you username : {username} of type : {type}")
                    
                    
                else:
                    print("something went wrong while registering the user")    
            else:
                print("invalid information")
        elif choice == 3:
            AppInput.conn.close()
            sys.exit(0)

    
    def _check_date_valids(self, birth_of_date):
        try:
            numbers = birth_of_date.split("-")
            year = int(numbers[0])
            month = int(numbers[1])
            day = int(numbers[2])
        except ValueError:
            return False

        return  True



class InvalidChoiceException(Exception):
    pass