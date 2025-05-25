Went with Lambda Container Image rather than a Lambda layer since this should be faster for cold starts

AWS offer a Lambda compatible image in [public ECR](https://gallery.ecr.aws/lambda/python) but obviously this does not have GDAL in it!

GDAL project [produce a Docker image](https://gdal.org/en/stable/download.html#containers) so started with that since it is already using a small Alpine image and their [Dockerfile](https://github.com/OSGeo/gdal/blob/master/Docker/alpine-normal/Dockerfile) looked gnarly so didn't want to recreate that on top of the AWS Lambda image.

To run a Docker container in Lambda, it needs the runtime interface client (RIC). This is available on PyPi [here](https://pypi.org/project/awsLambdaric). This was a pain to install, so perhaps experiment with which is easier to manage - installing GDAL on to of Lambda compatible image, or installing Lambda ric on the GDAL image?

use ```sam build --cached``` to avoid recreating the Docker image if the Dockerfile hasn't changed

The Dockerfile uses a multi-stage build to produce a smaller final image. Ideally split out the build of the initial larger image (which takes a couple of minutes) into your own base image to shorten development cycle for the smaller image with the lambda script.

##Observation on GDAL behaviour

GDAL wants to access the S3 bucket anonymously over https rather than using S3 properly; will need to download the image file first and then process locally - is this likely to be a problem?