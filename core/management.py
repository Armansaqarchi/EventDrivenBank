from dotenv import load_dotenv
from importlib import import_module
from .exceptions import ImproperlyConfigured
import settings
import os
import sys


class UtilizeManagement:
    """Encapsulate utilities"""
    
    def init(self, argv=None):
        self.argv = argv
        load_dotenv()
        self.connection, self.sql_dialect = self.connect_database()


    def get_commands(self):
        return os.getenv("COMMANDS")
    

    
    def connect_database(self):
        """function to test database connectivity and setting configuration"""

        try:
            sql_database = settings.db["DB_ADAPTER"]
            sql = import_module(sql_database)
            
            if sql_database == "psychopg":
                connection = sql.connect(
                    host= settings.db["HOST"],
                    port = settings.db["PORT"],
                    database = settings.db["DATABASE"],
                    user = settings.db["USER"],
                    password = settings.db["PASSWORD"]
                )
        except AttributeError:
            raise ImproperlyConfigured("settings.db is not configured properly")
        return connection, sql



    def help_text(self, commands_only = False) -> str:
        """stdout all the subcommands available"""


        commands = "here are the list of <subcommands> available :\n"
        try:
            commands_only = self.argv[2] == "--commands"
            if commands_only:
                for command, _ in os.environ.items:
                    commands.join("%s" + "\n" %command)
            return commands
        except(IndexError):
            pass
            for command, description in os.environ.items:
                    commands.join("%s     %s" %(command, description))

        return commands
    

    def exec_command(self):
        """get the subcommands and perform appropriate action"""

        try:
            subcommand = self.argv[1]
        except IndexError:
            subcommand = "help"


        if subcommand == "startapp":
            self.runapp()
            
        
        elif subcommand == "help":
            self.help_text()

        elif subcommand == "performdb":
            self.create_schema()
        

    def create_schema(self):
        """runs every sql command available in folder specified in setting"""
        filenames = os.listdir(settings.DDL_PATH)
        for filename in filenames:
            self._exec_sql(filename=filename)

            
    def _exec_sql(self, filename):

        """
        reads a sql filename and executes the file
        while executing commands, these exceptions might occur:
        ProgrammingError, OperationalError, IntegrityError, DataError, NotSupportedError
        """

        sql_file = open(filename, "r")
        sql_commands = sql_file.read()
        sql_file.close()

        cursor = self.connection.cursor()
        for command in sql_file.split(";"):
            cursor.execute(command)

        


        




                                
