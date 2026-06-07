FROM ghcr.io/lavalink-devs/lavalink:4
USER root
RUN mkdir -p /opt/Lavalink/plugins && wget -O /opt/Lavalink/plugins/youtube-plugin-1.17.0.jar https://maven.lavalink.dev/releases/dev/lavalink/youtube/youtube-plugin/1.17.0/youtube-plugin-1.17.0.jar
RUN printf 'server:\n  port: 2333\n  address: 0.0.0.0\nlavalink:\n  server:\n    password: "jarvisbot"\n    sources:\n      youtube: false\n      soundcloud: true\n      http: true\nplugins:\n  youtube:\n    enabled: true\n    allowSearch: true\n    clients:\n      - WEBEMBEDDED\n      - TV\n      - TVHTML5EMBEDDED\n      - WEB\n      - ANDROID_VR\n    oauth:\n      enabled: true\n      skipInitialization: false\nlogging:\n  level:\n    root: INFO\n    lavalink: INFO\n' > /opt/Lavalink/application.yml
WORKDIR /opt/Lavalink
