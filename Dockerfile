# Define custom function directory
ARG FUNCTION_DIR="/function"

FROM ghcr.io/osgeo/gdal:alpine-normal-latest-arm64 AS build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install necessary build tools; all of the below appear to be required for lambdaric and python gdal lib build
RUN apk update && apk add --no-cache python3-dev python3 py3-pip g++ make cmake unzip curl-dev autoconf automake libtool elfutils-dev

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Copy function code and requirements
COPY lambda_gdal ${FUNCTION_DIR}/lambda_gdal

# Install the function's dependencies
RUN pip install --target ${FUNCTION_DIR} awslambdaric
RUN pip install -r ${FUNCTION_DIR}/lambda_gdal/requirements.txt --target ${FUNCTION_DIR}

# Use a slim version of the base image to reduce the final image size
FROM ghcr.io/osgeo/gdal:alpine-small-latest-arm64

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# re-install just Python here again
RUN apk update && apk add --no-cache python3

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

# Make sure Python can find the modules
ENV PYTHONPATH=${FUNCTION_DIR}

# Set runtime interface client as default command for the container runtime
ENTRYPOINT [ "/usr/bin/python", "-m", "awslambdaric" ]

# Pass the name of the function handler as an argument to the runtime
# Format: <module_name>.<function_name>
CMD [ "lambda_gdal.lambda_gdal.lambda_handler" ]
