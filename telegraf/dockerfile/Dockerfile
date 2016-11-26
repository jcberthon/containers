FROM telegraf:1.1

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ntp \
    && apt-get clean -q \
    && rm -Rf /var/lib/apt/lists/*


