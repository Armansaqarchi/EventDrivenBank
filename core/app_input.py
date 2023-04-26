import sys
import settings



class AppInput:


    def input(self, *args) -> int:
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
        choice = input(settings.MAIN_MENU)

        if choice == 1:
            # perform withdraw
            amount = input("enter the amount of funds you would like to withdraw")
            
        
        elif choice == 2:
            # perform transfer

        elif choice == 3:
            sys.exit(0)

    
    def login_menu(self, *args) -> int:
        """
        invokes input function and performs login operations
        """
        choice = input(settings.LOGIN_MENU)

    
            




class InvalidChoiceException(Exception):
    pass