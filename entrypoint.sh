#!/bin/sh
set -e

SERVER_PORT="${PORT:-2333}"

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
    - dependency: "com.github.topi314.lavasrc:lavasrc-plugin:4.8.3"
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
    oauth:
      enabled: false
  lavasrc:
    providers:
      - "ytdlpsearch:%QUERY%"
      - "ytsearch:%QUERY%"
    sources:
      ytdlp: true
      youtube: false
      spotify: false
      applemusic: false
      deezer: false
    ytdlp:
      path: "yt-dlp"
      searchLimit: 10

logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
YAML

echo "✅ Lavalink: application.yml written (port $SERVER_PORT)"
echo "   yt-dlp version: $(yt-dlp --version 2>/dev/null || echo 'not found')"
exec java -Xmx${LAVALINK_HEAP:-400m} -XX:+UseG1GC -jar /opt/Lavalink/Lavalink.jar
