import logging
import importlib
import settings
import sys
from .core.management import UtilizeManagement


# set logger to info level, used to help debugging
logging.basicConfig(
level=importlib.import_module(settings.LOGGING.get("level"))
)

logger = logging.getLogger(__name__)

def main():
    """main function to run from configs and subcommands"""
    command_runner = UtilizeManagement(sys.argv)
    command_runner.exec_command()
    


if __name__ == "__main__":
    main()