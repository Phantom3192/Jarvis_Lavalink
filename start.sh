#!/bin/sh
set -e

if [ ! -f Lavalink.jar ]; then
  echo "Downloading Lavalink.jar..."
  curl -L -o Lavalink.jar https://github.com/lavalink-devs/Lavalink/releases/latest/download/Lavalink.jar
fi

# Start bgutil-pot in the background if it's not already present.
# NOTE: downloaded into the current working directory, NOT /usr/local/bin —
# this container's filesystem is read-only outside the working dir.
if [ ! -f ./bgutil-pot ]; then
  echo "Downloading bgutil-pot..."
  curl -L -o ./bgutil-pot https://github.com/jim60105/bgutil-ytdlp-pot-provider-rs/releases/latest/download/bgutil-pot-linux-x86_64
  chmod +x ./bgutil-pot
fi
./bgutil-pot server --host 127.0.0.1 --port 4416 &

# Start Lavalink
java -Xmx${LAVALINK_HEAP:-400m} -jar Lavalink.jar &
LAVALINK_PID=$!

# Wait for Lavalink to come up, then do an initial token push
sleep 15
chmod +x ./refresh_potoken.sh
./refresh_potoken.sh || echo "Initial poToken push failed, will retry on next cron tick"

wait $LAVALINK_PID
