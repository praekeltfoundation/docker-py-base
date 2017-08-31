ARG FROM_IMAGE=python:3-slim
FROM $FROM_IMAGE
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://jessie.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

ENV GOSU_VERSION="1.10" \
    GOSU_GPG_KEY="B42F6819007F00F88E364FD4036A9C25BF357DD4" \
    TINI_VERSION="0.16.1" \
    TINI_GPG_KEY="595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7"
RUN set -xe; \
    apt-get-install.sh wget; \
    \
# Install gosu
    wget -O gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"; \
    wget -O gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_GPG_KEY"; \
    gpg --batch --verify gosu.asc gosu; \
    rm -r "$GNUPGHOME" gosu.asc; \
    chmod +x gosu; \
    mv gosu /usr/local/sbin/gosu; \
# Link `gosu` as `su-exec` for compatibility with Alpine Linux
    ln -s /usr/local/sbin/gosu /usr/local/sbin/su-exec; \
    su-exec nobody true; \
    \
# Install tini
    wget -O tini "https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini-amd64"; \
    wget -O tini.asc "https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini-amd64.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$TINI_GPG_KEY"; \
    gpg --batch --verify tini.asc tini; \
    rm -r "$GNUPGHOME" tini.asc; \
    chmod +x tini; \
    mv tini /usr/local/sbin/tini; \
# Link `tini` as `dumb-init` and `dinit` for compatibility with older images
    ln -s /usr/local/sbin/tini /usr/local/sbin/dumb-init; \
    dumb-init -s -- true; \
    ln -s /usr/local/sbin/tini /usr/local/sbin/dinit; \
    dinit -s -- true; \
    \
    apt-get-purge.sh wget

# Set tini as the default entrypoint
ENTRYPOINT ["tini", "--"]
# HACK: detect which Python we have and run it
CMD ["/bin/sh", "-ec", \
     "for py in pypy3 pypy python3 python2; do \
         if PATH=/usr/local/bin command -v \"$py\"  > /dev/null; then \
             exec \"$py\"; \
         fi; \
      done"]
