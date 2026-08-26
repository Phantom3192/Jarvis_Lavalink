#!/usr/bin/env bash
#
# refresh_potoken.sh
#
# Fetches a real visitorData session id from YouTube, asks a
# locally-running bgutil-pot server for a poToken bound to it, then
# pushes both into Lavalink's youtube-source plugin via its REST
# hot-reload endpoint, so tokens never go stale without needing a
# Lavalink restart.
#
# Requires: curl, jq, grep -P (GNU grep)

BGUTIL_POT_URL="http://127.0.0.1:4416/get_pot"
LAVALINK_BASE_URL="${LAVALINK_BASE_URL:-http://127.0.0.1:26169}"
LAVALINK_PASSWORD="${LAVALINK_PASSWORD:?Set LAVALINK_PASSWORD in the environment}"

set -uo pipefail   # NOTE: deliberately NOT using -e here — every step
                    # below checks its own result and prints a clear
                    # message, so we don't want a single failed
                    # command to kill the script silently.

# --------------------------------------------------------------------
# 0. Dependency check — this is the #1 suspect for a silent failure
#    on a stripped-down container image.
# --------------------------------------------------------------------

for bin in curl jq grep; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "❌ Required tool '$bin' is not installed in this container."
    exit 1
  fi
done

if ! grep -P '' <<<'test' >/dev/null 2>&1; then
  echo "❌ 'grep -P' (PCRE) is not supported in this container's grep build."
  exit 1
fi

# --------------------------------------------------------------------
# 1. Get a fresh visitorData from YouTube's homepage.
# --------------------------------------------------------------------

homepage="$(curl -sf 'https://www.youtube.com/' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')"
curl_status=$?

if [[ $curl_status -ne 0 ]]; then
  echo "❌ Could not reach youtube.com (curl exit code $curl_status)."
  exit 1
fi

visitor_data="$(grep -oP '"visitorData":"\K[^"]+' <<<"$homepage" | head -n1)"

if [[ -z "$visitor_data" ]]; then
  echo "❌ Fetched youtube.com but couldn't find visitorData in the page."
  exit 1
fi

echo "ℹ️  Got visitorData (${#visitor_data} chars)."

# --------------------------------------------------------------------
# 2. Ask bgutil-pot for a poToken bound to that visitorData.
# --------------------------------------------------------------------

bgutil_response="$(curl -sf -X POST "$BGUTIL_POT_URL" \
  -H "Content-Type: application/json" \
  -d "{\"content_binding\": \"$visitor_data\"}")"
curl_status=$?

if [[ $curl_status -ne 0 ]]; then
  echo "❌ Could not reach bgutil-pot at $BGUTIL_POT_URL (curl exit code $curl_status)."
  exit 1
fi

po_token="$(jq -r '.poToken // .po_token // empty' <<<"$bgutil_response")"

if [[ -z "$po_token" ]]; then
  echo "❌ Could not extract poToken from bgutil-pot response:"
  echo "$bgutil_response"
  exit 1
fi

echo "ℹ️  Got poToken (${#po_token} chars)."

# --------------------------------------------------------------------
# 3. Push into Lavalink. Try the unversioned path first (per
#    youtube-source's own README), fall back to /v4 if that 404s.
# --------------------------------------------------------------------

update_payload="$(jq -n --arg pot "$po_token" --arg vd "$visitor_data" \
  '{poToken: $pot, visitorData: $vd}')"

push_token() {
  local path="$1"
  curl -s -o /tmp/lavalink_pot_response.json -w '%{http_code}' \
    -X POST "$LAVALINK_BASE_URL$path" \
    -H "Authorization: $LAVALINK_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "$update_payload"
}

http_code="$(push_token /youtube)"
echo "ℹ️  POST $LAVALINK_BASE_URL/youtube -> HTTP $http_code"

if [[ "$http_code" == "404" ]]; then
  http_code="$(push_token /v4/youtube)"
  echo "ℹ️  Fallback POST $LAVALINK_BASE_URL/v4/youtube -> HTTP $http_code"
fi

if [[ "$http_code" == "204" ]]; then
  echo "✅ Lavalink poToken/visitorData refreshed successfully."
else
  echo "❌ Lavalink rejected the update (HTTP $http_code):"
  cat /tmp/lavalink_pot_response.json 2>/dev/null
  exit 1
fi
