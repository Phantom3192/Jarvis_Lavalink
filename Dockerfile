FROM ghcr.io/lavalink-devs/lavalink:4

USER root

RUN apt-get update && apt-get install -y python3 python3-pip ffmpeg curl \
    && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER lavalink

WORKDIR /opt/Lavalink

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
