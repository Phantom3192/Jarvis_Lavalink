#!/bin/sh
set -e

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
      soundcloud: false
      http: true
      twitch: false
      vimeo: false
      nico: false
  # youtube-plugin is fetched automatically here (current as of writing: 1.18.1).
  # Bump this version string occasionally — YouTube changes break old plugin
  # versions regularly, so check https://github.com/lavalink-devs/youtube-source/releases
  # every so often and update VERSION below if playback issues come back.
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
      enabled: true
$(if [ -n "$LAVALINK_YT_REFRESH_TOKEN" ]; then
  echo "      refreshToken: \"$LAVALINK_YT_REFRESH_TOKEN\""
else
  echo "      # No LAVALINK_YT_REFRESH_TOKEN set yet."
  echo "      # On first boot, watch this service's deploy logs for a one-time"
  echo "      # device-login URL + code from YouTube (printed within the first"
  echo "      # ~30 seconds of startup). Open the URL, sign in with a SECONDARY"
  echo "      # Google account (not your main one), enter the code."
  echo "      # Lavalink will then print a refreshToken value in the logs —"
  echo "      # copy it, add it as the LAVALINK_YT_REFRESH_TOKEN variable on"
  echo "      # this Railway service, then redeploy. After that, no more"
  echo "      # logins are needed; the token is reused automatically."
fi)

logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
    dev.lavalink.youtube.http.YoutubeOauth2Handler: INFO
YAML

echo "✅ Lavalink: application.yml written"
echo "   OAuth refresh token: $([ -n "$LAVALINK_YT_REFRESH_TOKEN" ] && echo "SET" || echo "NOT SET — watch logs below for a login URL")"
echo ""

exec java \
  -Xmx${LAVALINK_HEAP:-400m} \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -jar /opt/Lavalink/Lavalink.jar
