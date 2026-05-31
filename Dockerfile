FROM ghcr.io/lavalink-devs/lavalink:4
COPY application.yml /opt/Lavalink/application.yml
RUN cat /opt/Lavalink/application.yml
