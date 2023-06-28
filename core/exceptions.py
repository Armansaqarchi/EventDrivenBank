import traceback

class ImproperlyConfigured(Exception):

    def __init__(self, message):
        self.message = message
        self.stacktrace = traceback.format_exc()


    def __str__(self):
        print(f"{self.message} + \n + {self.stacktrace}")
