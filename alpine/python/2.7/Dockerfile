FROM python:2.7.13-alpine3.6
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# Install libffi as it is small and means we get working cffi
RUN apk add --no-cache libffi

# Install su-exec and tini
RUN set -xe; \
    apk add --no-cache su-exec tini; \
    mkdir /usr/local/sbin; \
# Link `su-exec` as `gosu` for compatibility with Debian
    ln -s "$(which su-exec)" /usr/local/sbin/gosu; \
    gosu nobody true; \
# Link `tini` as `dumb-init` and `dinit` for compatibility with older images
    ln -s "$(which tini)" /usr/local/sbin/dumb-init; \
    dumb-init -s -- true; \
    ln -s "$(which tini)" /usr/local/sbin/dinit; \
    dinit -s -- true

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://alpine-3-6.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

# Set tini as the default entrypoint
ENTRYPOINT ["tini"]
CMD ["python"]
