FROM ghcr.io/hassio-addons/debian-base:stable

COPY infinitude-src/ /infinitude/

RUN apt-get update && apt-get install -y --no-install-recommends \
    make cpanminus \
        libmojolicious-perl libchi-perl libdatetime-perl libpath-tiny-perl libjson-perl libxml-simple-perl libmoo-perl libio-stty-perl \
        locales-all libdata-parsebinary-perl libdigest-crc-perl libhash-asobject-perl \
        bash jq \
    && apt-get remove --purge -y \
        make cpanminus \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    APP_SECRET="Pogotudinal" \
    PASS_REQS="1020" \
    MODE="Production" \
    SERIAL_TTY="" \
    SERIAL_SOCKET=""

EXPOSE 3000

COPY run.sh /

CMD ["/run.sh"]
