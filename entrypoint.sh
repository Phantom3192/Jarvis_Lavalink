#!/bin/sh
set -e

SERVER_PORT="${PORT:-2333}"

# Write YouTube cookies from env var to file
if [ -n "$YOUTUBE_COOKIES" ]; then
  echo "$YOUTUBE_COOKIES" | base64 -d > /opt/Lavalink/cookies.txt
  echo "✅ cookies: written successfully"
else
  echo "⚠️  cookies: YOUTUBE_COOKIES not set, yt-dlp may get bot-detected"
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
      customLoadArgs: ["-q", "--no-warnings", "--flat-playlist", "--skip-download", "-J", "--cookies", "/opt/Lavalink/cookies.txt"]
      customPlaybackArgs: ["-q", "--no-warnings", "-f", "bestaudio/best", "-J", "--cookies", "/opt/Lavalink/cookies.txt"]

logging:
  level:
    root: INFO
    lavalink: INFO
YAML

echo "✅ Lavalink ready on port $SERVER_PORT"
echo "   yt-dlp: $(yt-dlp --version 2>/dev/null || echo 'NOT FOUND')"

unset _JAVA_OPTIONS
exec java \
  -Xmx256m \
  -Xms64m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -XX:MaxMetaspaceSize=80m \
  -XX:+UseStringDeduplication \
  -jar /opt/Lavalink/Lavalink.jar
