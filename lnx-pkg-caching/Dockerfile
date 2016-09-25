FROM ubuntu:16.04

RUN mkdir -p -m 0775 /var/cache/apt-cacher-ng \
    && chown root:106 /var/cache/apt-cacher-ng
VOLUME ["/var/cache/apt-cacher-ng"]

RUN apt update \
    && apt install -y --no-install-recommends apt-cacher-ng \
    && apt-get clean -q && rm -Rf /var/lib/apt/lists/*

EXPOSE 3142

CMD /etc/init.d/apt-cacher-ng start && tail -f /var/log/apt-cacher-ng/*
