#!/bin/sh
cat > /opt/Lavalink/application.yml << 'EOF'
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
  youtube:
    enabled: true
    allowSearch: true
    clients:
      - MUSIC
      - WEB
    oauth:
      enabled: true
      refreshToken: "1//05zVuCjENM7puCgYIARAAGAUSNwF-L9IrfKS7fv40hWIQkuXhK4FxTMt3AYI8qrpBUh3d6hDuH2TkEKSlAj22UsVZDh_K2vjyCNA"

logging:
  level:
    root: INFO
    lavalink: INFO
EOF
exec java -jar /opt/Lavalink/Lavalink.jar
