FROM alpine:3.3
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install utility scripts
COPY ./common/scripts /scripts
# COPY ./alpine/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.0.2" \
    DINIT_SHA256="a8defac40aaca2ca0896c7c5adbc241af60c7c3df470c1a4c469a860bd805429"
RUN set -x \
    && apk add --no-cache ca-certificates curl \
    && DINIT_FILE="dumb-init_${DINIT_VERSION}_amd64" \
    && curl -sSL -o /usr/bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_FILE" \
    && echo "$DINIT_SHA256 */usr/bin/dumb-init" | sha256sum -c - \
    && chmod +x /usr/bin/dumb-init \
    && ln -s /usr/bin/dumb-init /usr/local/bin/dinit \
    && apk del ca-certificates curl

# Set dinit as the default entrypoint
ENTRYPOINT ["eval-args.sh", "dinit"]

# Set sh as the default command. Single child mode is necessary to avoid
# warnings when launching sh because of this issue in dumb-init:
# https://github.com/Yelp/dumb-init/issues/51
CMD ["--single-child", "--", "sh"]
