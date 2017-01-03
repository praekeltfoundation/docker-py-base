FROM python:3.6.0-slim
MAINTAINER Praekelt.org <sre@praekelt.org>

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://jessie.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY ./common/scripts /scripts
COPY ./debian/scripts /scripts
ENV PATH $PATH:/scripts

ENV DINIT_VERSION="1.2.0" \
    DINIT_SHA256="9af7440986893c904f24c086c50846ddc5a0f24864f5566b747b8f1a17f7fd52" \
    GOSU_VERSION="1.10"
RUN set -x \
    && apt-get-install.sh curl \
# Install dumb-init
    && DINIT_DEB_FILE="dumb-init_${DINIT_VERSION}_amd64.deb" \
    && curl -fsL -o /tmp/$DINIT_DEB_FILE "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_DEB_FILE" \
    && echo "$DINIT_SHA256 */tmp/$DINIT_DEB_FILE" | sha256sum -c - \
    && dpkg --install /tmp/$DINIT_DEB_FILE \
    && rm /tmp/$DINIT_DEB_FILE \
    && ln -s $(which dumb-init) /usr/local/bin/dinit \
    && dinit true \
# Install gosu
    && curl -fsL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && curl -fsL -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && ln -s $(which gosu) /usr/local/bin/su-exec \
    && su-exec nobody true \
    \
    && apt-get-purge.sh curl

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
CMD ["python"]
