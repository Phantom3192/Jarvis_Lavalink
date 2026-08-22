#!/bin/sh
set -e

if [ ! -f Lavalink.jar ]; then
  echo "Downloading Lavalink.jar..."
  curl -L -o Lavalink.jar https://github.com/lavalink-devs/Lavalink/releases/latest/download/Lavalink.jar
fi

exec java -Xmx${LAVALINK_HEAP:-400m} -jar Lavalink.jar
