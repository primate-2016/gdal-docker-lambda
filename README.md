# GDAL Docker Lambda

You will need **Docker** installed before you can use this repo. The image specifically uses arm64 architecture (to target Graviton) and so needs to be built on a Mac or other arm64 chip, or you will need to make it multi-architecture..?

This repo creates an AWS container Lambda function with the capability to use [GDAL](https://gdal.org/en/stable/).

To use it, clone the repo, setup your AWS creds and run:

```
sam build
sam deploy
```

You will then get a container image in ECR, a Lambda function and an S3 bucket. Upload an image to the S3 bucket to trigger the Lambda function which will then log some metadata about the image to show gdal is working. The initial Docker image build takes a while (about 3 minutes on my mac) during which you won't get any output from sam (it will display "Setting DockerBuildArgs for GdalLambdaFunction function" during the initial build)

I went with Lambda Container Image rather than a Lambda layer since this should be faster for cold starts

AWS offer a Lambda compatible image in [public ECR](https://gallery.ecr.aws/lambda/python) but obviously this does not have GDAL in it!

GDAL project [produce a Docker image](https://gdal.org/en/stable/download.html#containers) so started with that since it is already using a small Alpine image and their [Dockerfile](https://github.com/OSGeo/gdal/blob/master/Docker/alpine-normal/Dockerfile) looked gnarly so didn't want to try to recreate that on top of the AWS Lambda image.

To run a Docker container in Lambda, it needs the runtime interface client (RIC). This is available on PyPi [here](https://pypi.org/project/awsLambdaric). This dependencies to install this were quite involved to get working on Alpine, so perhaps experiment with which is easier to manage - installing GDAL on to of Lambda compatible image, or installing Lambda ric on the GDAL image?

Use ```sam build --cached``` to avoid recreating the Docker image if the Dockerfile hasn't changed

The Dockerfile uses a multi-stage build to produce a smaller final image. Ideally split out the build of the initial larger image (which takes a couple of minutes) into your own base image to shorten development cycle for the smaller image with the lambda script.
