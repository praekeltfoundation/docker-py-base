FROM pypy:2-5.1.1-slim
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://pypi.p16n.org/simple"

# Install utility scripts
ADD ./common/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.0.2" \
    DINIT_SHA256="4adc8eaf54d93e29b5f8e779d5a2165222a8f7f1bf9976c1f65e9379bba6fe08"
RUN set -x \
    && apt-get-install.sh curl \
    && cd /tmp \
    && DINIT_DEB_FILE="dumb-init_${DINIT_VERSION}_amd64.deb" \
    && curl -sSL -O "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_DEB_FILE" \
    && echo "$DINIT_SHA256 *$DINIT_DEB_FILE" | sha256sum -c - \
    && dpkg --install $DINIT_DEB_FILE \
    && rm $DINIT_DEB_FILE \
    && ln -s $(which dumb-init) /usr/local/bin/dinit \
    && apt-get-purge.sh curl

# Set dinit as the default entrypoint
ENTRYPOINT ["eval-args.sh", "dinit"]
CMD ["pypy"]
