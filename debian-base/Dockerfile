FROM debian:8.3
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install utility scripts
ADD ./scripts /scripts
ENV PATH $PATH:/scripts

# Download dinit (dumb-init)
ENV DINIT_VERSION "1.0.0"
RUN apt-get-install.sh ca-certificates curl #&& \
    curl -LSs -o /usr/local/bin/dumb-init \
        https://github.com/Yelp/dumb-init/releases/download/v${DINIT_VERSION}/dumb-init_${DINIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    ln -s /usr/local/bin/dumb-init /usr/local/bin/dinit && \
    apt-get-purge.sh ca-certificates curl

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
