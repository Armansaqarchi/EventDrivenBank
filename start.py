import sys
import os
import logging
import importlib
import settings

# set logger to info level, used to help debugging
logger = logging.basicConfig(
level=importlib.import_module(settings.LOGGING.get("level"))
)

def main():
    """main function to run from configs and subcommands"""
    

    




if __name__ == "__main__":
    main()