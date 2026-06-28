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
    bufferDurationMs: 225
    frameBufferDurationMs: 5000
    opusEncodingQuality: 5
    resamplingQuality: MEDIUM
    trackStuckThresholdMs: 5000
    playerUpdateInterval: 3
    useSeekGhosting: true
    gc-warnings: true
  plugins:
    - dependency: "dev.lavalink.youtube:youtube-plugin:1.18.1"
      snapshot: false
    - dependency: "com.github.topi314.lavasrc:lavasrc-plugin:4.8.3"
      repository: "https://maven.lavalink.dev/releases"
    - dependency: "com.github.topi314.lavasearch:lavasearch-plugin:1.0.0"
      repository: "https://maven.lavalink.dev/releases"
    - dependency: "com.dunctebot:skybot-lavalink-plugin:1.7.1"
      repository: "https://maven.lavalink.dev/releases"
    - dependency: "com.github.devoxin:lavadspx-plugin:0.0.5"
      repository: "https://jitpack.io"
    - dependency: "com.github.topi314.lavalyrics:lavalyrics-plugin:1.1.0"
      repository: "https://maven.lavalink.dev/releases"
    - dependency: "me.duncte123:java-lyrics-plugin:1.6.6"
      repository: "https://maven.lavalink.dev/releases"

plugins:
  youtube:
    enabled: true
    allowSearch: true
    allowDirectVideoIds: true
    allowDirectPlaylistIds: true
    clients:
      - "TVHTML5_SIMPLY"
      - "ANDROID_MUSIC"
      - "MUSIC"
      - "WEB"
      - "WEBEMBEDDED"
    TVHTML5_SIMPLY:
      playback: true
      playlistLoading: true
      searching: true
      videoLoading: true
    ANDROID_MUSIC:
      playlistLoading: false
      videoLoading: true
      searching: true
      playback: true
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
    WEBEMBEDDED:
      playlistLoading: false
      videoLoading: false
      searching: false
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
      flowerytts: true
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
    flowerytts:
      voice: "${FLOWERY_VOICE:-Olivia}"
      translate: false
      silence: 0
      speed: ${FLOWERY_SPEED:-1.0}
      audioFormat: "${FLOWERY_AUDIO_FORMAT:-mp3}"

  lavalyrics:
    sources:
      - youtube

  dunctebot:
    ttsLanguage: "en-US"
    sources:
      getyarn: true
      clypit: true
      tts: true
      reddit: true
      ocremix: true
      tiktok: true
      mixcloud: true
      soundgasm: true

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
  -Xmx256m \
  -Xms64m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=50 \
  -XX:MaxMetaspaceSize=80m \
  -XX:+UseStringDeduplication \
  -jar /opt/Lavalink/Lavalink.jar
