ARG FROM_IMAGE=python:3-alpine3.6
FROM $FROM_IMAGE
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

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
ENTRYPOINT ["tini", "--"]
# HACK: detect which Python we have and run it
CMD ["/bin/sh", "-ec", \
     "for py in pypy3 pypy python3 python2; do \
         if PATH=/usr/local/bin command -v \"$py\"  > /dev/null; then \
             exec \"$py\"; \
         fi; \
      done"]
