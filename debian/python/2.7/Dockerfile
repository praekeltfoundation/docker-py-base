FROM python:2.7.13-slim
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://jessie.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

ENV DINIT_VERSION="1.2.0" \
    DINIT_SHA256="9af7440986893c904f24c086c50846ddc5a0f24864f5566b747b8f1a17f7fd52"
ENV GOSU_VERSION="1.10" \
    GOSU_GPG_KEY="B42F6819007F00F88E364FD4036A9C25BF357DD4"
RUN set -xe; \
    apt-get-install.sh wget; \
# Install dumb-init
    wget -O dumb-init.deb "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/dumb-init_${DINIT_VERSION}_amd64.deb"; \
    echo "$DINIT_SHA256 *dumb-init.deb" | sha256sum -c -; \
    dpkg --install dumb-init.deb; \
    rm dumb-init.deb; \
    ln -s $(which dumb-init) /usr/local/bin/dinit; \
    dinit true; \
# Install gosu
    wget -O gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"; \
    wget -O gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_GPG_KEY"; \
    gpg --batch --verify gosu.asc gosu; \
    rm -r "$GNUPGHOME" gosu.asc; \
    chmod +x gosu; \
    mv gosu /usr/local/bin/gosu; \
    ln -s /usr/local/bin/gosu /usr/local/bin/su-exec; \
    su-exec nobody true; \
    apt-get-purge.sh wget

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
CMD ["python"]
