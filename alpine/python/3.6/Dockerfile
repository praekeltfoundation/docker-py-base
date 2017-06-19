FROM python:3.6.1-alpine
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# Install su-exec and tini
RUN set -xe; \
    apk add --no-cache su-exec tini; \
    mkdir /usr/local/sbin; \
# Link `su-exec` as `gosu` for compatibility with Debian
    ln -s "$(which su-exec)" /usr/local/sbin/gosu; \
# Remove the script at /usr/bin/tini warning that tini is really at /sbin/tini
    rm /usr/bin/tini; \
# Link `tini` as `dumb-init` and `dinit` for compatibility with older images
    ln -s "$(which tini)" /usr/local/sbin/dumb-init; \
    dumb-init -s -- true; \
    ln -s "$(which tini)" /usr/local/sbin/dinit; \
    dinit -s -- true

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://alpine-3-4.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

# Set tini as the default entrypoint
ENTRYPOINT ["tini"]
CMD ["python"]
