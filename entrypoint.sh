#!/bin/sh
set -e

if [ -z "$LAVALINK_COOKIES_B64" ]; then
    echo "⚠️  LAVALINK_COOKIES_B64 is not set — YouTube may block requests."
    echo "    See entrypoint.sh comments for how to generate and set it."
    COOKIES_FILE=""
else
    COOKIES_FILE="/opt/Lavalink/cookies.txt"
    echo "$LAVALINK_COOKIES_B64" | base64 -d > "$COOKIES_FILE"
    echo "✅ Lavalink: cookies decoded to $COOKIES_FILE"
fi

# ── Write application.yml ─────────────────────────────────────────────────────
cat > /opt/Lavalink/application.yml << YAML
server:
  port: 2333
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
  youtube:
    enabled: true
    allowSearch: true
    allowDirectVideoIds: true
    allowDirectPlaylistIds: true
    clients:
      - TVHTML5SIMPLY
      - MUSIC
      - WEB
      - ANDROID
    oauth:
      enabled: false      # OAuth disabled — using cookies instead
$(if [ -n "$COOKIES_FILE" ]; then
  echo "    pot:"
  echo "      cookiesFile: \"$COOKIES_FILE\""
else
  echo "    # pot: cookiesFile not set (LAVALINK_COOKIES_B64 missing)"
fi)

logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
YAML

echo "✅ Lavalink: application.yml written"
echo "   Cookies: $([ -n "$COOKIES_FILE" ] && echo "$COOKIES_FILE" || echo "NOT SET")"

exec java \
  -Xmx256m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -jar /opt/Lavalink/Lavalink.jar
