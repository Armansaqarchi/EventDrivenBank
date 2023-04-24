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



    def help_text(self, commands_only = False) -> str:
        """stdout all the subcommands available"""


        commands = "here are the list of <subcommands> available :\n"
        try:
            if self.argv[2] == "--commands":
                for command, _ in os.environ.items:
                    commands.join("%s" + "\n" %command)
            return commands
        except(IndexError):
            pass

            for command, description in os.environ.items:
                    commands.join("%s     %s" %(command, description))

        return commands

