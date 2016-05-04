FROM python:2.7.11-slim
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://pypi.p16n.org/simple"

# Install utility scripts
ADD ./common/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION "1.0.1"
RUN set -x \
    && apt-get-install.sh curl \
    && cd /tmp \
    && DINIT_DEB_FILE="dumb-init_${DINIT_VERSION}_$(dpkg --print-architecture).deb" \
    && curl -sSL -O "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_DEB_FILE" \
    && curl -sSL "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/sha256sums" | \
        grep "\s\*\?$DINIT_DEB_FILE$" | sha256sum -c - \
    && dpkg --install $DINIT_DEB_FILE \
    && rm $DINIT_DEB_FILE \
    && ln -s $(which dumb-init) /usr/local/bin/dinit \
    && apt-get-purge.sh curl

# Set dinit as the default entrypoint
ENTRYPOINT ["eval-args.sh", "dinit"]
CMD ["python"]
