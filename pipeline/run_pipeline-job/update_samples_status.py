import sys
import datetime

from pymongo import MongoClient


def main():
    sample = DB.samples.find_one({'id': RUN})
    sample['pipeline_analysis']['date'].append(
        datetime.datetime.now().strftime("%d %B, %Y - %H:%M:%S"))
    sample['pipeline_analysis']['status'].append(STATUS)
    DB.samples.update_one({'id': RUN}, {'$set': sample})
    if STATUS == 'pipeline finished':
        # TODO Start export job
        pass


if __name__ == "__main__":
    # Get run name from command line
    RUN = sys.argv[1]

    # Get status from command line
    STATUS = sys.argv[2]

    # Getting access to MongoDB
    CLIENT = MongoClient('mongodb://samples-logs-db-svc')
    DB = CLIENT.samples
    main()
