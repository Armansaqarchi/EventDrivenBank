from dotenv import dotenv_values
from importlib import import_module
from .exceptions import ImproperlyConfigured
import settings
from core.app_input import AppInput
import os
from psycopg2 import OperationalError
from psycopg2 import errors
import psycopg2
from start import logger

class UtilizeManagement:
    """Encapsulate utilities"""
    
    def __init__(self, argv=None):
        self.argv = argv
        self.env = dotenv_values(os.path.join(settings.BASE_DIR, "envs.env"))
        


    def _get_commands(self):
        return os.getenv("COMMANDS")
    

    
    def _connect_database(self):
        """function to test database connectivity and setting configuration"""

        try:
            connection = psycopg2.connect(
            host= settings.db["HOST"],
            port = settings.db["PORT"],
            database = settings.db["DATABASE"],
            user = settings.db["USER"],
            password = settings.db["PASSWORD"]
            )

        except AttributeError:
            raise ImproperlyConfigured("settings.db is not configured properly")
        except OperationalError:
            raise ImproperlyConfigured("could not establish connection to database, are you sure all the migrations are applied to database?")
        return connection



    def _help_text(self, commands_only = False) -> str:
        """stdout all the subcommands available"""

        commands = "here are the list of <subcommands> available :\n\n\n"
        try:
            commands_only = self.argv[2] == "--commands"
            if commands_only:
                for command, _ in self.env.items():
                    commands.join("%s" + "\n" %command)
            return commands
        except IndexError :
            for command, description in self.env.items():
                    print(command, description)
                    commands += "{:<10}:{:<20}\n".format(command, description)

        return commands
    

    def exec_command(self):
        """get the subcommands and perform appropriate action"""

        try:
            subcommand = self.argv[1]
        except IndexError:
            subcommand = "help"

        if subcommand == "startapp":
            self.connection = self._connect_database()
            application_input = AppInput(connection= self.connection)
            while True:
                application_input.login_menu()      
        
        elif subcommand == "help":
            commands = self._help_text()
            print(commands)

        elif subcommand == "performdb":
            self.connection = self._connect_database()
            self._create_schema()

    def _create_schema(self):
        """runs every sql command available in folder specified in setting"""


        table_filenames = os.listdir(settings.DDL_PATH.get("tables"))
        procedure_filenames = os.listdir(settings.DDL_PATH.get("procedures"))
        logger.info(f"creating database ddl, running scripts in {settings.DDL_PATH.get('tables')}")
        for filename in table_filenames: 
            # making abs path of the given file
            filename = settings.DDL_PATH.get("tables") + "/" + filename
            self._exec_ddls(file_dir=filename)
        
        logger.info(f"creating database procedures, running scripts in {settings.DDL_PATH.get('procedures')}")
        for filename in procedure_filenames:
            if not filename.endswith(".sql"):
                continue
            
            filename = settings.DDL_PATH.get("procedures") + "/" + filename
            self._exec_ddls(file_dir=filename)
        self.connection.commit()

            
    def _exec_ddls(self, file_dir):
        
        """
        reads a sql filename and executes the file
        while executing commands, these exceptions might occur:
        ProgrammingError, OperationalError, IntegrityError, DataError, NotSupportedError
        """

        
        sql_file = open(file_dir, "r")
        sql_commands = sql_file.read()
        sql_file.close()
        try:
            logger.info(f"running sql file {file_dir}")
            cursor = self.connection.cursor()
            cursor.execute(sql_commands)
        except errors.DuplicateObject as e:
            logger.warning("entity already exists : ", str(e))
            pass



    def _cron_configuration():
        cron = import_module("crontab").Crontab()

        for command in settings.CRONTAB.get("command"):
            job = cron.new(command)
            job.setall("0 * * * *")
        
        cron.write()



        




                                
