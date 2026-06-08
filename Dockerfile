FROM ghcr.io/lavalink-devs/lavalink:4

USER root

RUN printf 'server:\n  port: 2333\n  address: 0.0.0.0\n\nlavalink:\n  server:\n    password: "jarvisbot"\n    sources:\n      youtube: false\n      soundcloud: true\n      http: true\n\nlogging:\n  level:\n    root: INFO\n    lavalink: INFO\n' > /opt/Lavalink/application.yml

WORKDIR /opt/Lavalink

EXPOSE 2333
