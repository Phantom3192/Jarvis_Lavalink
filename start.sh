#!/bin/sh
set -e

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "node/npm not found — downloading a portable Node.js runtime (no system install needed)..."
  NODE_VERSION="22.11.0"
  if [ ! -d "./node-runtime" ]; then
    curl -L -o node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
    mkdir -p ./node-runtime
    tar -xJf node.tar.xz -C ./node-runtime --strip-components=1
    rm -f node.tar.xz
  fi
  export PATH="$(pwd)/node-runtime/bin:$PATH"
  if ! command -v node >/dev/null 2>&1; then
    echo "❌ Portable Node.js extraction failed — this container may lack xz/tar support. Extraction needs 'tar -xJf' to work; check that xz-utils (or equivalent) is available."
    exit 1
  fi
  echo "✅ Using portable Node $(node -v) from ./node-runtime"
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
