#!/usr/bin/env bash
# Get a Zoom OBF (On-Behalf-Of) token for the Meeting SDK.
# OBF is per meeting and valid ~2 hours. The user whose token we use must be in the meeting.
# Use with: ./bin/entry.sh --on-behalf "$OBF" (or set on-behalf= in config.toml)
#
# Prerequisites:
# 1. Zoom OAuth app with scope user:read:token (same app as ZAK can have both user:read:zak and user:read:token).
# 2. Refresh token for the Zoom user who will be in the meeting (the "chaperone" — e.g. dmitry@vexa.ai).
#
# Usage:
#   MEETING_ID=12345678901 [Option A or B] ./scripts/get-obf.sh
#
#   Option A - You have an access token:
#     ZOOM_ACCESS_TOKEN="your_access_token" MEETING_ID=12345678901 ./scripts/get-obf.sh
#
#   Option B - You have refresh token + OAuth app credentials:
#     ZOOM_CLIENT_ID="..." ZOOM_CLIENT_SECRET="..." ZOOM_REFRESH_TOKEN="..." MEETING_ID=12345678901 ./scripts/get-obf.sh
#
# Output: prints the OBF token to stdout.

set -e

if [[ -z "$MEETING_ID" ]]; then
  echo "MEETING_ID is required (the meeting the bot will join on behalf of the user)." >&2
  exit 1
fi

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
  echo "Set MEETING_ID and either ZOOM_ACCESS_TOKEN or (ZOOM_CLIENT_ID + ZOOM_CLIENT_SECRET + ZOOM_REFRESH_TOKEN)." >&2
  exit 1
fi

RESP=$(curl -s -X GET "$ZOOM_API_BASE/users/me/token?type=onbehalf&meeting_id=$MEETING_ID" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

# Zoom returns { "token": "eyJ..." } for the OBF
OBF=$(echo "$RESP" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [[ -z "$OBF" ]]; then
  echo "Failed to get OBF. Response: $RESP" >&2
  exit 1
fi

echo "$OBF"
