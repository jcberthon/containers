FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends ntp \
    && apt-get clean -q \
    && rm -Rf /var/lib/apt/lists/*

RUN chgrp root /var/lib/ntp && chmod g+w /var/lib/ntp

EXPOSE 123/udp

ENTRYPOINT ["/usr/sbin/ntpd"]
