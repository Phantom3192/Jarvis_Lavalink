FROM ghcr.io/lavalink-devs/lavalink:4

USER root

RUN apt-get update && apt-get install -y python3 ffmpeg curl \
    && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
       -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /opt/Lavalink/plugins \
    && curl -L https://github.com/bongo-devs/jiosaavn-plugin/releases/download/v1.0.6/jiosaavn-plugin-1.0.6.jar \
       -o /opt/Lavalink/plugins/jiosaavn-plugin-1.0.6.jar \
    && chown -R lavalink:lavalink /opt/Lavalink/plugins

USER lavalink

WORKDIR /opt/Lavalink

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
