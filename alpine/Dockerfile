FROM alpine:3.5
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

RUN apk add --no-cache su-exec

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.2.0" \
    DINIT_SHA256="81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363"
RUN set -x \
    && apk add --no-cache ca-certificates curl \
    && DINIT_FILE="dumb-init_${DINIT_VERSION}_amd64" \
    && curl -sSL -o /usr/bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_FILE" \
    && echo "$DINIT_SHA256 */usr/bin/dumb-init" | sha256sum -c - \
    && chmod +x /usr/bin/dumb-init \
    && ln -s /usr/bin/dumb-init /usr/local/bin/dinit \
    && apk del ca-certificates curl

# Install utility scripts
# COPY scripts /scripts
# ENV PATH $PATH:/scripts

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
CMD ["sh"]
