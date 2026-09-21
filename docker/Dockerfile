FROM docker.io/nebulous/infinitude:latest@sha256:10172dfabbdae3336b442ed9072db35c53301abb992730cff4a315fd18f088e2 AS app

FROM ghcr.io/hassio-addons/base:21.0.0@sha256:26c14772d1eb72c8aa7f0b6866a2bc13ada705f77b8c263fcfa09116a5e00e25

ARG BUILD_DATE=unknown
ARG BUILD_REF=unknown
ARG BUILD_VERSION=dev

RUN apk add --no-cache \
        perl-mojolicious \
        perl-chi \
        perl-datetime \
        perl-path-tiny \
        perl-json \
        perl-xml-simple \
        perl-moo \
        perl-io-tty

# The digest-pinned upstream image already contains these pure-Perl modules.
# Copying them keeps rebuilds tied to that reviewed digest instead of CPAN's
# mutable latest versions.
COPY --from=app /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=app /usr/local/share/perl5 /usr/local/share/perl5
COPY --from=app /infinitude /infinitude

COPY rootfs /

EXPOSE 3000

LABEL \
    io.hass.name="Infinitude" \
    io.hass.description="Infinitude proxy/UI for Carrier Infinity thermostats" \
    io.hass.type="app" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Eric Miller <1588827+sosheskaz@users.noreply.github.com>" \
    org.opencontainers.image.authors="Eric Miller <1588827+sosheskaz@users.noreply.github.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Home Assistant add-on packaging for Infinitude" \
    org.opencontainers.image.documentation="https://github.com/sosheskaz/infinitude-ha-addon/blob/main/README.md" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.source="https://github.com/sosheskaz/infinitude-ha-addon" \
    org.opencontainers.image.title="Infinitude Home Assistant Add-on" \
    org.opencontainers.image.url="https://github.com/sosheskaz/infinitude-ha-addon" \
    org.opencontainers.image.vendor="sosheskaz" \
    org.opencontainers.image.version="${BUILD_VERSION}"
