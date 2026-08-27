#!/bin/sh
set -e

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "node/npm not found — downloading a portable Node.js runtime (no system install needed)..."
  NODE_VERSION="22.22.1"
  if [ ! -x "./node-runtime/bin/node" ] || [ "$(cat ./node-runtime/.version 2>/dev/null)" != "$NODE_VERSION" ]; then
    rm -rf ./node-runtime node.tar.xz
    set +e   # diagnose each step ourselves instead of letting -e hide which one failed

    http_code="$(curl -sS -w '%{http_code}' -o node.tar.xz -L "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz")"
    curl_status=$?
    echo "ℹ️  curl exit=$curl_status, HTTP status=$http_code, downloaded size=$(wc -c < node.tar.xz 2>/dev/null || echo 0) bytes"

    if [ "$curl_status" -ne 0 ] || [ "$http_code" != "200" ]; then
      echo "❌ Download failed (curl exit $curl_status, HTTP $http_code). Showing first 300 bytes of what we got, in case it's an error page:"
      head -c 300 node.tar.xz 2>/dev/null
      echo
      exit 1
    fi

    echo "ℹ️  File type check: $(file node.tar.xz 2>/dev/null || echo 'file(1) not available')"

    mkdir -p ./node-runtime
    if ! command -v xz >/dev/null 2>&1; then
      echo "ℹ️  No system xz found."
      if command -v apt-get >/dev/null 2>&1; then
        echo "ℹ️  apt-get present (whoami: $(whoami 2>&1)) — attempting install..."
        timeout 25 apt-get update -qq 2>&1 | tail -5
        timeout 25 apt-get install -y -qq xz-utils 2>&1 | tail -10
      elif command -v apk >/dev/null 2>&1; then
        echo "ℹ️  apk present (whoami: $(whoami 2>&1)) — attempting install..."
        timeout 25 apk add --no-cache xz 2>&1 | tail -10
      else
        echo "ℹ️  Neither apt-get nor apk found on this system at all."
      fi
    fi

    if command -v xz >/dev/null 2>&1; then
      echo "✅ xz available ($(command -v xz))"
      tar -xJf node.tar.xz -C ./node-runtime --strip-components=1
      tar_status=$?
    else
      echo "ℹ️  Package manager install unavailable/failed — fetching a static busybox (has its own xz decoder) as last resort."
      bb_http_code="$(curl -sS -m 30 -w '%{http_code}' -o busybox -L https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox)"
      bb_curl_status=$?
      echo "ℹ️  busybox curl exit=$bb_curl_status, HTTP status=$bb_http_code, size=$(wc -c < busybox 2>/dev/null || echo 0) bytes"
      if [ "$bb_curl_status" -ne 0 ] || [ "$bb_http_code" != "200" ]; then
        echo "❌ busybox download failed too (curl exit $bb_curl_status, HTTP $bb_http_code). First 300 bytes of response:"
        head -c 300 busybox 2>/dev/null
        echo
        exit 1
      fi
      chmod +x busybox
      ./busybox xz -dc node.tar.xz > node.tar
      tar -xf node.tar -C ./node-runtime --strip-components=1
      tar_status=$?
      rm -f node.tar busybox
    fi
    if [ "$tar_status" -ne 0 ]; then
      echo "❌ tar extraction failed with exit code $tar_status — see tar's own error output above."
      exit 1
    fi
    echo "$NODE_VERSION" > ./node-runtime/.version
    rm -f node.tar.xz

    set -e
  fi
  export PATH="$(pwd)/node-runtime/bin:$PATH"
  if ! command -v node >/dev/null 2>&1; then
    echo "❌ node binary still not found on PATH after extraction — check ./node-runtime/bin contents manually."
    ls -la ./node-runtime/bin 2>/dev/null
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
