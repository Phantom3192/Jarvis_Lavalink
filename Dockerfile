FROM ghcr.io/lavalink-devs/lavalink:4
RUN mkdir -p /opt/Lavalink/plugins && \
    wget -O /opt/Lavalink/plugins/youtube-plugin-1.18.1.jar \
    https://maven.lavalink.dev/releases/dev/lavalink/youtube/youtube-plugin/1.18.1/youtube-plugin-1.18.1.jar
RUN find / -name "application.yml" 2>/dev/null
COPY application.yml /opt/Lavalink/application.yml
