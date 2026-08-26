#!/bin/sh
set -e

if [ ! -f Lavalink.jar ]; then
  echo "Downloading Lavalink.jar..."
  curl -L -o Lavalink.jar https://github.com/lavalink-devs/Lavalink/releases/latest/download/Lavalink.jar
fi

# Start bgutil-pot in the background if it's not already running
if [ ! -f /usr/local/bin/bgutil-pot ]; then
  echo "Downloading bgutil-pot..."
  curl -L -o /usr/local/bin/bgutil-pot https://github.com/jim60105/bgutil-ytdlp-pot-provider-rs/releases/latest/download/bgutil-pot-linux-x86_64
  chmod +x /usr/local/bin/bgutil-pot
fi
/usr/local/bin/bgutil-pot server --host 127.0.0.1 --port 4416 &

# Start Lavalink
java -Xmx${LAVALINK_HEAP:-400m} -jar Lavalink.jar &
LAVALINK_PID=$!

# Wait for Lavalink to come up, then do an initial token push
sleep 15
./refresh_potoken.sh || echo "Initial poToken push failed, will retry on next cron tick"

wait $LAVALINK_PID
