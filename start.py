import logging
import importlib
import settings
import sys



# set logger to info level, used to help debugging
logging.basicConfig(
level = getattr(logging, settings.LOGGING["level"]),
)

logger = logging.getLogger(__name__)

# creating console handler to change log format
ch = logging.StreamHandler()


def main():

    sys.path.append(settings.BASE_DIR)


    from core.management import UtilizeManagement
    """main function to run from configs and subcommands"""
    command_runner = UtilizeManagement(argv = sys.argv)
    command_runner.exec_command()
    


if __name__ == "__main__":
    main()