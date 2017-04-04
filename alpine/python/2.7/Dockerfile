FROM python:2.7.13-alpine
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# Install libffi as it is required by cffi and present in the Debian images
RUN apk add --no-cache \
        libffi \
        su-exec

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.2.0" \
    DINIT_SHA256="81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363"
RUN set -xe; \
    apk add --no-cache wget; \
    wget -O dumb-init "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/dumb-init_${DINIT_VERSION}_amd64"; \
    echo "$DINIT_SHA256 *dumb-init" | sha256sum -c -; \
    chmod +x dumb-init; \
    mv dumb-init /usr/bin/dumb-init; \
    ln -s /usr/bin/dumb-init /usr/local/bin/dinit; \
    apk del wget

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://alpine-3.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
CMD ["python"]
