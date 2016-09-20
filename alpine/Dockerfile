FROM alpine:3.4
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

RUN apk add --no-cache su-exec

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.1.3" \
    DINIT_SHA256="1af305fc011c72aa899c88fe6576e82f2c7657d8d5212a13583fd2de012e478f"
RUN set -x \
    && apk add --no-cache ca-certificates curl \
    && DINIT_FILE="dumb-init_${DINIT_VERSION}_amd64" \
    && curl -sSL -o /usr/bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_FILE" \
    && echo "$DINIT_SHA256 */usr/bin/dumb-init" | sha256sum -c - \
    && chmod +x /usr/bin/dumb-init \
    && ln -s /usr/bin/dumb-init /usr/local/bin/dinit \
    && apk del ca-certificates curl

# Install utility scripts
COPY ./common/scripts /scripts
# COPY ./alpine/scripts /scripts
ENV PATH $PATH:/scripts

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]

# Set sh as the default command. Single child mode is necessary to avoid
# warnings when launching sh because of this issue in dumb-init:
# https://github.com/Yelp/dumb-init/issues/51
CMD ["--single-child", "--", "sh"]
