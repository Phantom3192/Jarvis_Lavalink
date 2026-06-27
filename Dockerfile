FROM ghcr.io/lavalink-devs/lavalink:4

WORKDIR /opt/Lavalink

RUN mkdir -p plugins && \
    wget -q -O plugins/youtube-plugin.jar \
    "https://github.com/lavalink-devs/youtube-source/releases/download/1.13.2/youtube-plugin-1.13.2.jar"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
