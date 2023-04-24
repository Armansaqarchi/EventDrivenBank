from dotenv import load_dotenv
import os
import sys

class UtilizeManagement:
    """Encapsulate utilities"""
    
    def init(self, argv=None):
        self.argv = argv
        load_dotenv()


    def get_commands(self):
        return os.getenv("COMMANDS")



    def help_text(self, commands_only = False):
        try:
            only_commands = self.argv[2]
            for command, _ in os.environ.items:
                sys.stdout.write("")
        except(IndexError):

