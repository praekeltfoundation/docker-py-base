FROM debian:8.6
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install utility scripts
COPY ./common/scripts /scripts
COPY ./debian/scripts /scripts
ENV PATH $PATH:/scripts

ENV DINIT_VERSION="1.1.3" \
    DINIT_SHA256="34995cf69c88311e9475b4d101186b1d5f4d653f222e41c6e5643ff4e6f56f54" \
    GOSU_VERSION="1.9"
RUN set -x \
    && apt-get-install.sh ca-certificates curl \
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
    && apt-get-purge.sh ca-certificates curl

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]

# Set Bash as the default command. Single child mode is necessary to avoid
# warnings when launching Bash because of this issue in dumb-init:
# https://github.com/Yelp/dumb-init/issues/51
CMD ["--single-child", "--", "bash"]
