#!/bin/sh
set -e

SERVER_PORT="${PORT:-2333}"

if [ -n "$LAVALINK_YT_REFRESH_TOKEN" ]; then
  CLEAN_TOKEN="$(echo "$LAVALINK_YT_REFRESH_TOKEN" | tr -d '[:space:]')"
  OAUTH_BLOCK="    oauth:
      enabled: true
      refreshToken: \"$CLEAN_TOKEN\""
else
  OAUTH_BLOCK="    oauth:
      enabled: true"
fi

cat > /opt/Lavalink/application.yml << YAML
server:
  port: $SERVER_PORT
  address: 0.0.0.0
lavalink:
  server:
    password: "${LAVALINK_PASSWORD:-jarvisbot}"
    sources:
      youtube: false
      soundcloud: false
      http: true
  plugins:
    - dependency: "dev.lavalink.youtube:youtube-plugin:1.18.1"
      repository: "https://maven.lavalink.dev/releases"
plugins:
  youtube:
    enabled: true
    allowSearch: true
    allowDirectVideoIds: true
    allowDirectPlaylistIds: true
    clients:
      - MUSIC
      - ANDROID_MUSIC
      - WEB
      - WEBEMBEDDED
      - TV
$OAUTH_BLOCK
logging:
  level:
    root: INFO
    lavalink: INFO
YAML

echo "Lavalink ready on port $SERVER_PORT"
exec java -Xmx${LAVALINK_HEAP:-400m} -XX:+UseG1GC -jar /opt/Lavalink/Lavalink.jar
