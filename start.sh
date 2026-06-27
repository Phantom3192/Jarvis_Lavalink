#!/bin/sh
set -e

LAVALINK_DIR="$(cd "$(dirname "$0")" && pwd)/lavalink"
mkdir -p "$LAVALINK_DIR"

PORT="${LAVALINK_PORT:-8000}"

cat > "$LAVALINK_DIR/application.yml" << YAML
server:
  port: $PORT
  address: 0.0.0.0

lavalink:
  server:
    password: "${LAVALINK_PASSWORD:-jarvisbot}"
    sources:
      youtube: false
      soundcloud: false
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
      - MUSIC
      - WEB
      - WEBEMBEDDED
      - TV
    oauth:
      enabled: false

logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
    dev.lavalink.youtube.http.YoutubeOauth2Handler: INFO
YAML

echo "Lavalink: application.yml written (port $PORT)"
echo "   Password: ${LAVALINK_PASSWORD:+SET (custom)}"
echo "   YouTube OAuth: disabled (set LAVALINK_YT_OAUTH=true to enable once you have a valid token)"
echo ""

cd "$LAVALINK_DIR"
exec java \
  -Xmx${LAVALINK_HEAP:-400m} \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -jar "$LAVALINK_DIR/Lavalink.jar"
