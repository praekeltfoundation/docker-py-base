ARG FROM_IMAGE=python:3-alpine3.7
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

# pip: Disable cache and use Praekelt.org Python Package Index
RUN set -ex; \
    codename="alpine-$(cat /etc/alpine-release | grep -oE ^[0-9]+\.[0-9]+ | tr '.' '-')"; \
    echo '[global]' > /etc/pip.conf; \
# `no-cache-dir = false` is not intuitive--it's translated to a CLI option and does disable the cache
    echo 'no-cache-dir = false' >> /etc/pip.conf; \
    echo "extra-index-url = https://$codename.wheelhouse.praekelt.org/simple" >> /etc/pip.conf

# Install utility scripts
COPY scripts /scripts
ENV PATH $PATH:/scripts

# Set tini as the default entrypoint
ENTRYPOINT ["tini", "--"]
# No PyPy on Alpine, and the base image symlinks `python3` as `python`
CMD ["python"]
