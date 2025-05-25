import json
import urllib.parse
import logging
from osgeo import gdal

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    logger.info(f"event: {json.dumps(event)}")

    # Extract bucket and key from the first record in the Lambda event
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    gtif = gdal.Open(f"/vsis3/{bucket}/{key}")
    logger.info(f"gtif metadata: {gtif.GetMetadata()}")

    # bucket = event['Records'][0]['s3']['bucket']['name']
    # s3key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    # print(bucket)
    # print(s3key)
    # print(event)
    
