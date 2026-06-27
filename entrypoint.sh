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
      enabled: false"
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
      soundcloud: true
      http: true
      twitch: false
      vimeo: false
      nico: false
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
      - TVHTML5_SIMPLY
      - MUSIC
      - IOS
$OAUTH_BLOCK
logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
    dev.lavalink.youtube.http.YoutubeOauth2Handler: INFO
YAML

echo "✅ Lavalink: application.yml written (port $SERVER_PORT)"
echo "   Password: ${LAVALINK_PASSWORD:+SET (custom)}${LAVALINK_PASSWORD:-DEFAULT (jarvisbot)}"
exec java -Xmx${LAVALINK_HEAP:-400m} -XX:+UseG1GC -jar /opt/Lavalink/Lavalink.jar
