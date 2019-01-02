# Build Python library into binary

FROM alpine:3.7

ARG GST_VERSION=0.12.0
ARG GST_TAR_URL=https://github.com/Aalto-LeTech/greedy-string-tiling/archive/v$GST_VERSION.tar.gz

WORKDIR /tmp/gst

# Install dependencies for compilation environment
RUN apk --update --no-cache add tar curl python3-dev g++ \
    && curl --location $GST_TAR_URL | tar --extract --gunzip --strip-components 1 \
    && python3 setup.py bdist_egg


# Install the built Python binary

FROM alpine:3.7

WORKDIR /var/gst
# Copy from previous build stage
COPY --from=0 /tmp/gst/dist .

# Compile the library and install runtime dependencies for the async worker (celery)
RUN apk --update --no-cache add python3 libstdc++ \
    && python3 -m easy_install ./greedy_string_tiling-*.egg \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install celery

# Start a single celery worker on a single cpu, producing completed matching tasks to gst_matchlib_tasks
ENTRYPOINT python3 -m celery worker \
    --app matchlib.celerymain \
    --concurrency 1 \
    --queue gst_matchlib_tasks \
    --loglevel INFO
