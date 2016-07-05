FROM python:3.5.2-slim
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://pypi.p16n.org/simple"

# wheel isn't installed in Python 3 by default
RUN pip install wheel

# Install utility scripts
COPY ./common/scripts /scripts
COPY ./debian/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.1.1" \
    DINIT_SHA256="6a8c0aba1db90c5fffa7e2bbd4d4cda4905563cebd829ec89f8704733bdd71c0"
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
CMD ["python"]
