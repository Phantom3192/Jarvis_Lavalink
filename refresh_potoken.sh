#!/usr/bin/env bash
#
# refresh_potoken.sh
#
# Fetches a real visitorData session id from YouTube, asks a
# locally-running bgutil-pot server for a poToken bound to it, then
# pushes both into Lavalink's youtube-source plugin via its REST
# hot-reload endpoint (POST /youtube), so tokens never go stale
# without needing a Lavalink restart.
#
# Requires: curl, jq, grep -P (GNU grep)
#
# --------------------------------------------------------------------
# CONFIG - edit these for your setup
# --------------------------------------------------------------------

# Where bgutil-pot's HTTP server is listening (run alongside Lavalink)
BGUTIL_POT_URL="http://127.0.0.1:4416/get_pot"

# Your Lavalink node's own base URL (NOT the wavelink identifier)
LAVALINK_BASE_URL="http://127.0.0.1:2333"

# Same password as `lavalink.server.password` / your LAVALINK_PASSWORD env var
LAVALINK_PASSWORD="${LAVALINK_PASSWORD:?Set LAVALINK_PASSWORD in the environment}"

set -euo pipefail

# --------------------------------------------------------------------
# 1. Get a fresh visitorData from YouTube itself.
#    bgutil-pot does NOT generate this — it only mints a poToken bound
#    to whatever content_binding you give it. visitorData is YouTube's
#    own anonymous session identifier, embedded in the homepage's
#    ytcfg blob on every page load.
# --------------------------------------------------------------------

visitor_data="$(curl -sf 'https://www.youtube.com/' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
  | grep -oP '"visitorData":"\K[^"]+' | head -n1)"

if [[ -z "$visitor_data" ]]; then
  echo "❌ Could not extract visitorData from youtube.com homepage."
  exit 1
fi

# --------------------------------------------------------------------
# 2. Ask bgutil-pot for a poToken bound to that visitorData.
# --------------------------------------------------------------------

response="$(curl -sf -X POST "$BGUTIL_POT_URL" \
  -H "Content-Type: application/json" \
  -d "{\"content_binding\": \"$visitor_data\"}")"

po_token="$(echo "$response" | jq -r '.poToken // .po_token // empty')"

if [[ -z "$po_token" ]]; then
  echo "❌ Could not extract poToken from bgutil-pot response:"
  echo "$response"
  exit 1
fi

# --------------------------------------------------------------------
# 3. Push the fresh poToken + visitorData into Lavalink (no restart needed).
# --------------------------------------------------------------------

update_payload="$(jq -n \
  --arg pot "$po_token" \
  --arg vd "$visitor_data" \
  '{poToken: $pot, visitorData: $vd}')"

http_code="$(curl -s -o /tmp/lavalink_pot_response.json -w '%{http_code}' \
  -X POST "$LAVALINK_BASE_URL/v4/youtube" \
  -H "Authorization: $LAVALINK_PASSWORD" \
  -H "Content-Type: application/json" \
  -d "$update_payload")"

if [[ "$http_code" == "204" ]]; then
  echo "✅ Lavalink poToken/visitorData refreshed successfully."
else
  echo "❌ Lavalink rejected the update (HTTP $http_code):"
  cat /tmp/lavalink_pot_response.json
  exit 1
fi
