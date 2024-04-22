ARG INFINITUDE_BASE=docker.io/nebulous/infinitude:latest
FROM ${INFINITUDE_BASE}

RUN apt-get update && apt-get install -y \
    bash \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /

MAINTAINER "Eric Miller (sosheskaz)"

ENTRYPOINT ["/run.sh"]
