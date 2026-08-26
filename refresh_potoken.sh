#!/usr/bin/env bash
#
# refresh_potoken.sh
#
# Polls a locally-running bgutil-pot HTTP server for a fresh YouTube
# PO Token + visitorData pair, then pushes it into Lavalink's
# youtube-source plugin via its REST hot-reload endpoint
# (POST /youtube), so tokens never go stale without needing a
# Lavalink restart.
#
# Requires: curl, jq
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

# --------------------------------------------------------------------
# 1. Ask bgutil-pot for a fresh token.
#    Leaving content_binding empty requests a visitorData-bound
#    (session-wide) token rather than a per-video one, which is what
#    you want for the WEB client here.
# --------------------------------------------------------------------

set -euo pipefail

response="$(curl -sf -X POST "$BGUTIL_POT_URL" \
  -H "Content-Type: application/json" \
  -d '{"content_binding": ""}')"

# NOTE: Verify these field names against your bgutil-pot version first —
# run: curl -sX POST http://127.0.0.1:4416/get_pot -H "Content-Type: application/json" -d '{"content_binding": ""}' | jq .
# and adjust the two jq paths below to match whatever keys you actually see.
po_token="$(echo "$response" | jq -r '.po_token // .poToken // empty')"
visitor_data="$(echo "$response" | jq -r '.visit_identifier // .visitorData // .visitor_data // empty')"

if [[ -z "$po_token" || -z "$visitor_data" ]]; then
  echo "❌ Could not extract po_token/visitor_data from bgutil-pot response:"
  echo "$response"
  exit 1
fi

# --------------------------------------------------------------------
# 2. Push the fresh token into Lavalink (no restart needed).
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
