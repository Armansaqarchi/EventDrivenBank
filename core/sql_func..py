import re
import os
import settings


def get_function_script(function_name, file_path):
    file = open(os.path.join(settings.BASE_DIR, file_path))
    content = file.read()
    file.close()
    pattern = f""
    



