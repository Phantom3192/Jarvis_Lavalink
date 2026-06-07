FROM ghcr.io/lavalink-devs/lavalink:4
USER root
RUN cat > /opt/Lavalink/application.yml << 'EOF'
server:
  port: 2333
  address: 0.0.0.0
lavalink:
  server:
    password: "jarvisbot"
    sources:
      youtube: false
      soundcloud: true
      http: true
  plugins:
    - dependency: "dev.lavalink.youtube:youtube-plugin:1.18.1"
      repository: "https://maven.lavalink.dev/releases"
plugins:
  youtube:
    enabled: true
    allowSearch: true
    clients:
      - WEBEMBEDDED
      - TV
      - TVHTML5EMBEDDED
      - WEB
      - ANDROID_VR
    oauth:
      enabled: true
      skipInitialization: true
      refreshToken: "1//060V0B6e076aSCgYIARAAGAYSNwF-L9Ir_23nphBBxpjdqL9Lgm-yvT50mijwfvN6lTaRoddlYzt3p4jV5A99e4BxBCUmRgMmMiM"
    cipherSolver:
      remoteCipherUrl: "http://noble-serenity.railway.internal:8080"
logging:
  level:
    root: INFO
    lavalink: INFO
EOF
WORKDIR /opt/Lavalink
