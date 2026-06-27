#!/bin/sh
set -e

# Railway sets PORT automatically; fallback to 2333 for other hosts
SERVER_PORT="${PORT:-2333}"

# ── Write application.yml ─────────────────────────────────────────────────────
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
      - ANDROID_MUSIC
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

echo "✅ Lavalink: application.yml written (port $SERVER_PORT)"
echo "   Password: ${LAVALINK_PASSWORD:+SET (custom)}"
echo ""

exec java \
  -Xmx${LAVALINK_HEAP:-400m} \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -jar /opt/Lavalink/Lavalink.jar
