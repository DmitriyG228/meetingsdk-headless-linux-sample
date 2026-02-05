#!/usr/bin/env bash
# Get a Zoom ZAK (Zoom Access Key) token for the Meeting SDK.
# ZAK is short-lived (~5 min). Use it with: ./bin/entry.sh --zak "$ZAK" (or set zak= in config.toml)
#
# Prerequisites:
# 1. Create a Zoom OAuth app at https://marketplace.zoom.us/ (Build App → OAuth / General App).
# 2. In the app: add Redirect URL (e.g. http://localhost:8080/callback) and scope user:read:zak (Scopes).
# 3. Get a refresh token (one-time): open authorize URL with scope=user:read:zak, sign in, then exchange code for tokens.
#
# Usage:
#   Option A - You have an access token (e.g. from your backend):
#     ZOOM_ACCESS_TOKEN="your_access_token" ./scripts/get-zak.sh
#
#   Option B - You have refresh token + OAuth app credentials:
#     ZOOM_CLIENT_ID="..." ZOOM_CLIENT_SECRET="..." ZOOM_REFRESH_TOKEN="..." ./scripts/get-zak.sh
#
# Output: prints the ZAK token to stdout. Use within ~5 minutes.

set -e

ZOOM_API_BASE="https://api.zoom.us/v2"
ZOOM_OAUTH_TOKEN_URL="https://zoom.us/oauth/token"

if [[ -n "$ZOOM_ACCESS_TOKEN" ]]; then
  ACCESS_TOKEN="$ZOOM_ACCESS_TOKEN"
elif [[ -n "$ZOOM_REFRESH_TOKEN" && -n "$ZOOM_CLIENT_ID" && -n "$ZOOM_CLIENT_SECRET" ]]; then
  echo "Refreshing access token..." >&2
  BASIC_AUTH=$(echo -n "${ZOOM_CLIENT_ID}:${ZOOM_CLIENT_SECRET}" | base64 | tr -d '\n')
  RESP=$(curl -s -X POST "$ZOOM_OAUTH_TOKEN_URL" \
    -H "Authorization: Basic $BASIC_AUTH" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=refresh_token&refresh_token=$ZOOM_REFRESH_TOKEN")
  ACCESS_TOKEN=$(echo "$RESP" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
  if [[ -z "$ACCESS_TOKEN" ]]; then
    echo "Failed to refresh token. Response: $RESP" >&2
    exit 1
  fi
else
  echo "Set either ZOOM_ACCESS_TOKEN or (ZOOM_CLIENT_ID + ZOOM_CLIENT_SECRET + ZOOM_REFRESH_TOKEN)." >&2
  exit 1
fi

RESP=$(curl -s -X GET "$ZOOM_API_BASE/users/me/token?type=zak" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

# Zoom returns { "token": "eyJ..." } for the ZAK
ZAK=$(echo "$RESP" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [[ -z "$ZAK" ]]; then
  echo "Failed to get ZAK. Response: $RESP" >&2
  exit 1
fi

echo "$ZAK"
