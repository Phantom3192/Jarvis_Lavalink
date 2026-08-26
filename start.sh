#!/bin/sh
set -e

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "❌ node/npm not found in this container — webpo-generator needs Node.js installed on the image (bot-hosting.net's Java egg may not include it by default)."
  exit 1
fi

if [ ! -f Lavalink.jar ]; then
  echo "Downloading Lavalink.jar..."
  curl -L -o Lavalink.jar https://github.com/lavalink-devs/Lavalink/releases/latest/download/Lavalink.jar
fi

# Start webpo-generator in the background if it's not already present.
# Replaces the old bgutil-pot + refresh_potoken.sh flow: webpo-generator
# mints a poToken per request via Lavalink's remotePot config instead of
# pushing a single static token on a timer.
if [ ! -d ./webpo-generator ]; then
  echo "Cloning webpo-generator..."
  git clone https://github.com/ashton045/webpo-generator.git ./webpo-generator
  (cd ./webpo-generator && npm i)
fi
(cd ./webpo-generator && HOST=127.0.0.1 PORT=8080 npm start) &

# Start Lavalink
java -Xmx${LAVALINK_HEAP:-400m} -jar Lavalink.jar &
LAVALINK_PID=$!

wait $LAVALINK_PID
