FROM nebulous/infinitude

RUN apt-get update \
  && apt-get install -y tini \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY run.sh /

ENTRYPOINT ["/run.sh"]
