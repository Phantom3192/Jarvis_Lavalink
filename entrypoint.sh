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
    - dependency: "com.github.topi314.lavasrc:lavasrc-plugin:4.8.3"
      repository: "https://maven.lavalink.dev/releases"

plugins:
  lavasrc:
    providers:
      - "ytdlpsearch:%QUERY%"
    sources:
      ytdlp: true
      youtube: false
      spotify: false
      applemusic: false
      deezer: false
      soundcloud: false
    ytdlp:
      path: "yt-dlp"
      searchLimit: 10

logging:
  level:
    root: INFO
    lavalink: INFO
YAML

echo "✅ Lavalink ready on port $SERVER_PORT"
echo "   yt-dlp: $(yt-dlp --version 2>/dev/null || echo 'NOT FOUND - check Dockerfile')"
nset _JAVA_OPTIONS
exec java \
  -Xmx${LAVALINK_HEAP:-512m} \
  -Xms128m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -XX:MaxMetaspaceSize=128m \
  -XX:+UseStringDeduplication \
  -jar /opt/Lavalink/Lavalink.jar
