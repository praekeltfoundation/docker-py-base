FROM python:2.7.12-alpine
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# ca-certificates not installed in Alpine Python images for some reason:
# https://github.com/docker-library/python/issues/109
# Also install libffi as it is required by cffi and present in the Debian images
RUN apk add --no-cache ca-certificates libffi

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://alpine-3.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY ./common/scripts /scripts
COPY ./alpine/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.1.1" \
    DINIT_SHA256="87bdb684cf9ad20dcbdec47ee62389168fb530c024ccd026d95f888f16136e44"
RUN set -x \
    && apk add --no-cache curl \
    && DINIT_FILE="dumb-init_${DINIT_VERSION}_amd64" \
    && curl -sSL -o /usr/bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_FILE" \
    && echo "$DINIT_SHA256 */usr/bin/dumb-init" | sha256sum -c - \
    && chmod +x /usr/bin/dumb-init \
    && ln -s /usr/bin/dumb-init /usr/local/bin/dinit \
    && apk del curl

# Set dinit as the default entrypoint
ENTRYPOINT ["eval-args.sh", "dinit"]
CMD ["python"]
