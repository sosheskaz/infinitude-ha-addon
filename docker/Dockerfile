ARG INFINITUDE_BASE=docker.io/nebulous/infinitude:latest
FROM ${INFINITUDE_BASE} AS base

FROM alpine:latest AS getter

RUN apk --no-cache add jq

FROM base AS target

COPY --from=getter /usr/bin/jq /usr/bin/jq

COPY run.sh /

LABEL maintainer="Eric Miller (sosheskaz)"

ENTRYPOINT ["/run.sh"]
