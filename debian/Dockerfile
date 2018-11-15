ARG FROM_IMAGE=python:slim
FROM $FROM_IMAGE
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# pip: Disable cache and use Praekelt.org Python Package Index
RUN set -ex; \
    codename="$(. /etc/os-release; echo $VERSION | grep -oE [a-z]+)"; \
    echo '[global]' > /etc/pip.conf; \
# `no-cache-dir = false` is not intuitive--it's translated to a CLI option and does disable the cache
    echo 'no-cache-dir = false' >> /etc/pip.conf; \
    echo "extra-index-url = https://$codename.wheelhouse.praekelt.org/simple" >> /etc/pip.conf

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

ENV GOSU_VERSION="1.10" \
    GOSU_GPG_KEY="B42F6819007F00F88E364FD4036A9C25BF357DD4" \
    TINI_VERSION="0.18.0" \
    TINI_GPG_KEY="595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7"
RUN set -xe; \
    fetchDeps=" \
        wget \
# GPG not available by default on Stretch
        $(command -v gpg > /dev/null || echo 'dirmngr gnupg') \
    "; \
    apt-get-install.sh $fetchDeps; \
    \
# Install gosu
    wget -O gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"; \
    wget -O gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_GPG_KEY"; \
    gpg --batch --verify gosu.asc gosu; \
    { command -v gpgconf > /dev/null && gpgconf --kill all || :; }; \
    rm -rf "$GNUPGHOME" gosu.asc; \
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
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$TINI_GPG_KEY"; \
    gpg --batch --verify tini.asc tini; \
    { command -v gpgconf > /dev/null && gpgconf --kill all || :; }; \
    rm -rf "$GNUPGHOME" tini.asc; \
    chmod +x tini; \
    mv tini /usr/local/sbin/tini; \
# Link `tini` as `dumb-init` and `dinit` for compatibility with older images
    ln -s /usr/local/sbin/tini /usr/local/sbin/dumb-init; \
    dumb-init -s -- true; \
    ln -s /usr/local/sbin/tini /usr/local/sbin/dinit; \
    dinit -s -- true; \
    \
    apt-get-purge.sh $fetchDeps

# HACK: Make sure a Python is available as `python`. Only necessary for PyPy.
RUN set -ex; \
    if ! command -v python > /dev/null; then \
        cd /usr/local/bin; \
        for py in pypy3 pypy python3 python2; do \
            [ -x "$py" ] && ln -s "$py" python || true; \
        done; \
        readlink -e python; \
    fi

# Set tini as the default entrypoint
ENTRYPOINT ["tini", "--"]
CMD ["python"]
