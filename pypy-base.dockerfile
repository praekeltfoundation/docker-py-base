FROM pypy:2-5.0.1-slim
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://pypi.p16n.org/simple"

# Install utility scripts
ADD ./common/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION "1.0.1"
ADD ./common/dumb-init_${DINIT_VERSION}_amd64 /usr/local/bin/dumb-init
RUN ln -s /usr/local/bin/dumb-init /usr/local/bin/dinit

# Set dinit as the default entrypoint
ENTRYPOINT ["eval-args.sh", "dinit"]
CMD ["pypy"]
