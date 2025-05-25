import json
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
