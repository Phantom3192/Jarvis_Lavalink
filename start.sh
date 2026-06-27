#!/bin/sh
set -e

LAVALINK_DIR="$(cd "$(dirname "$0")" && pwd)/lavalink"
mkdir -p "$LAVALINK_DIR"

PORT="${LAVALINK_PORT:-8000}"

# If a validated refresh token is stored, use it.
# Set LAVALINK_YT_OAUTH_READY=true alongside LAVALINK_YT_REFRESH_TOKEN to activate.
if [ "${LAVALINK_YT_OAUTH_READY:-false}" = "true" ] && [ -n "$LAVALINK_YT_REFRESH_TOKEN" ]; then
  OAUTH_BLOCK="    oauth:
      enabled: true
      refreshToken: \"$LAVALINK_YT_REFRESH_TOKEN\""
  OAUTH_STATUS="ENABLED with stored refresh token"
else
  # No valid token yet — enable OAuth so Lavalink prints a device-login URL in the logs.
  # Follow the URL, sign in with a SECONDARY Google account, then copy the refreshToken
  # from the logs and add it as LAVALINK_YT_REFRESH_TOKEN secret.
  # Then also set LAVALINK_YT_OAUTH_READY=true to activate it on next restart.
  OAUTH_BLOCK="    oauth:
      enabled: true"
  OAUTH_STATUS="ENABLED (device-login flow — watch logs for a Google login URL)"
fi

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
$OAUTH_BLOCK

logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
    dev.lavalink.youtube.http.YoutubeOauth2Handler: INFO
YAML

echo "Lavalink: application.yml written (port $PORT)"
echo "   YouTube OAuth: $OAUTH_STATUS"
echo ""

cd "$LAVALINK_DIR"
exec java \
  -Xmx${LAVALINK_HEAP:-400m} \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -jar "$LAVALINK_DIR/Lavalink.jar"
