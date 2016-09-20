FROM python:3.5.2-alpine
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install libffi as it is required by cffi and present in the Debian images
RUN apk add --no-cache \
        libffi \
        su-exec

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.1.3" \
    DINIT_SHA256="1af305fc011c72aa899c88fe6576e82f2c7657d8d5212a13583fd2de012e478f"
RUN set -x \
    && apk add --no-cache curl \
    && DINIT_FILE="dumb-init_${DINIT_VERSION}_amd64" \
    && curl -sSL -o /usr/bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_FILE" \
    && echo "$DINIT_SHA256 */usr/bin/dumb-init" | sha256sum -c - \
    && chmod +x /usr/bin/dumb-init \
    && ln -s /usr/bin/dumb-init /usr/local/bin/dinit \
    && apk del curl

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://alpine-3.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY ./common/scripts /scripts
COPY ./alpine/scripts /scripts
ENV PATH $PATH:/scripts

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
CMD ["python"]
