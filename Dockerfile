FROM alpine:3.7
RUN apk add --no-cache python3-dev g++ git \
    && python3 -m pip install celery git+https://github.com/Aalto-LeTech/greedy-string-tiling.git
ENTRYPOINT python3 -m celery worker --app matchlib.celerymain --concurrency 1 --queue gst_matchlib_tasks --loglevel INFO
