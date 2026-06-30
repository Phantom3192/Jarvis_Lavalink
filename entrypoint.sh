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
    bufferDurationMs: 400
    frameBufferDurationMs: 5000
    opusEncodingQuality: 5
    resamplingQuality: LOW
    trackStuckThresholdMs: 10000
    playerUpdateInterval: 5
    useSeekGhosting: true
    gc-warnings: true
  plugins:
    - dependency: "dev.lavalink.youtube:youtube-plugin:1.18.1"
      snapshot: false
    - dependency: "com.github.topi314.lavasrc:lavasrc-plugin:4.8.3"
      repository: "https://maven.lavalink.dev/releases"

plugins:
  youtube:
    enabled: true
    allowSearch: true
    allowDirectVideoIds: true
    allowDirectPlaylistIds: true
    clients:
      - "TVHTML5_SIMPLY"
      - "MUSIC"
      - "WEB"
    TVHTML5_SIMPLY:
      playback: true
      playlistLoading: true
      searching: true
      videoLoading: true
    MUSIC:
      playlistLoading: false
      videoLoading: false
      searching: true
      playback: false
    WEB:
      playlistLoading: false
      videoLoading: true
      searching: true
      playback: true
    oauth:
      enabled: false

  lavasrc:
    providers:
      - 'ytsearch:"%ISRC%"'
      - "ytsearch:%QUERY%"
      - "ytdlpsearch:%QUERY%"
      - "scsearch:%QUERY%"
    sources:
      spotify: true
      applemusic: false
      deezer: false
      jiosaavn: false
      yandexmusic: false
      tidal: false
      vkmusic: false
      qobuz: false
      ytdlp: true
      youtube: true
      flowerytts: false
    lyrics-sources:
      youtube: true
      lrcLib: true
    spotify:
      countryCode: "${SPOTIFY_COUNTRY_CODE:-IN}"
      playlistLoadLimit: 6
      albumLoadLimit: 6
      resolveArtistsInSearch: true
      localFiles: false
      preferPartnerApi: false
      preferV1SearchApi: false
    ytdlp:
      path: "yt-dlp"
      searchLimit: ${SEARCH_LIMIT:-10}
      mixPlaylistLoadLimit: 25
      playlistLoadLimit: 1000
    youtube:
      countryCode: "${YOUTUBE_COUNTRY_CODE:-IN}"
      playlistLoadLimit: 1
      albumLoadLimit: 1
      artistLoadLimit: 1

  jiosaavn:
    apiURL: "${JIOSAAVN_API_URL:-https://jiosaavn-plugin-api.vercel.app/api}"
    playlistTrackLimit: 50
    recommendationsTrackLimit: 10

logging:
  level:
    root: INFO
    lavalink: INFO
    dev.lavalink.youtube: INFO
YAML

echo "✅ application.yml written on port $SERVER_PORT"
echo "   yt-dlp: $(yt-dlp --version 2>/dev/null || echo 'NOT FOUND')"

unset _JAVA_OPTIONS
exec java \
  -Xmx${LAVALINK_HEAP:-320m} \
  -Xms128m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -XX:MaxMetaspaceSize=96m \
  -XX:+UseStringDeduplication \
  -XX:+OptimizeStringConcat \
  -jar /opt/Lavalink/Lavalink.jar
