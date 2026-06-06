FROM ghcr.io/lavalink-devs/lavalink:4
USER root
RUN mkdir -p /opt/Lavalink/plugins && wget -O /opt/Lavalink/plugins/youtube-plugin-1.18.1.jar https://maven.lavalink.dev/releases/dev/lavalink/youtube/youtube-plugin/1.18.1/youtube-plugin-1.18.1.jar
RUN printf 'server:\n  port: 2333\n  address: 0.0.0.0\nlavalink:\n  server:\n    password: "jarvisbot"\n    sources:\n      youtube: false\n      soundcloud: true\n      http: true\nplugins:\n  youtube:\n    enabled: true\n    allowSearch: true\n    clients:\n      - MUSIC\n      - WEB\n      - ANDROID_VR\n      - TVHTML5_SIMPLY\n      - IOS\n    oauth:\n      enabled: true\n      skipInitialization: false\n      refreshToken: "1//06cCLkYO99gicCgYIARAAGAYSNwF-L9IrWMThDL5oK7o6TVtJXTAR9AsYYXtOXPJWFqSXxSnCA91bCsEVipLPhDsrhFH7VJD6gaI"\nlogging:\n  level:\n    root: INFO\n    lavalink: INFO\n' > /opt/Lavalink/application.yml
WORKDIR /opt/Lavalink
