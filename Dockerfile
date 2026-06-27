FROM ghcr.io/lavalink-devs/lavalink:4

WORKDIR /opt/Lavalink

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
