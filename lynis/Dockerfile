FROM ubuntu:16.04
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
         git \
         ca-certificates
RUN cd /opt/ && git clone https://github.com/CISOfy/lynis.git

WORKDIR /opt/lynis

ENTRYPOINT [ "./lynis", "audit", "system" ]
