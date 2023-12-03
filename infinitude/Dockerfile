FROM docker.io/nebulous/infinitude:latest

COPY run.sh /

RUN addgroup --gid 34500 infinitude \
  && adduser --system --uid 34500 --gid 34500 --home /infinitude infinitude \
  && chmod u-w,g-w,o-w /infinitude/* && chmod 755 /infinitude \
  && mkdir -p -m 755 /infinitude/state \
  && chown -R infinitude:infinitude /infinitude \
  && apt-get update \
  && apt-get install -y sudo \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/run.sh"]
