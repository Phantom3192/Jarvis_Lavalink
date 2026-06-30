FROM ghcr.io/lavalink-devs/lavalink:4

USER root

# Installed Java 21 here previously to support the standalone jiosaavn-plugin (now removed,
# since lavasrc 4.8.3 has native JioSaavn support). Kept for forward-compatibility with newer plugins.
RUN apt-get update && apt-get install -y python3 ffmpeg curl openjdk-21-jre-headless \
    && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
       -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /opt/Lavalink/plugins \
    && chown -R lavalink:lavalink /opt/Lavalink/plugins

USER lavalink

WORKDIR /opt/Lavalink

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
