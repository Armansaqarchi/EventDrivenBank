from core.app_input import AppInput
from start import logger
from datetime import datetime


def update_balances():
    """
    main function to handle updates,
    this function depends on cronjob handling
    cause this project is based on database,
    this function only aims for calling the related procedure in database every minute
    """

    connection = AppInput.conn
    cursor = connection.cursor()
    cursor.execute("CALL update_balance(%s::boolean)", [None])
    
    if cursor.fetchone()[0]:
        logger.log(f"updates are done successfully at {datetime.now()}")
        #creating snapshot_id tables, each table related to the last update balance occured
        cursor.execute('CALL create_snapshot(%s::boolean)', [None])
        AppInput.conn.commit()
        return 
        
    
    logger.warning("there was an error while trying to update all the events, make sure that there is no leak in data consistancy, or use the events to fix it")
    return

    




    