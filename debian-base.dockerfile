FROM debian:8.3
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Install utility scripts
ADD ./common/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION "1.0.0"
ADD ./common/dumb-init_${DINIT_VERSION}_amd64 /usr/local/bin/dumb-init
RUN ln -s /usr/local/bin/dumb-init /usr/local/bin/dinit

# Set dinit as the default entrypoint
ENTRYPOINT ["eval-args.sh", "dinit"]
