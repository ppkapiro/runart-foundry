#!/usr/bin/env bash
set -e
if [[ -z "$ACCESS_CLIENT_ID_PREVIEW" || -z "$ACCESS_CLIENT_SECRET_PREVIEW" || -z "$TARGET_HOST" ]]; then
  echo "Faltan variables de entorno necesarias." >&2
  exit 2
fi

OUT=$(curl -sI -H "CF-Access-Client-Id: $ACCESS_CLIENT_ID_PREVIEW" -H "CF-Access-Client-Secret: $ACCESS_CLIENT_SECRET_PREVIEW" "https://$TARGET_HOST/api/whoami")
STATUS=$(echo "$OUT" | head -n 1)
LOCATION=$(echo "$OUT" | grep -i '^Location:' | head -n1)
CANARY=$(echo "$OUT" | grep -i '^X-RunArt-Canary:' | head -n1)
RESOLVER=$(echo "$OUT" | grep -i '^X-RunArt-Resolver:' | head -n1)

SUMMARY="Status: $STATUS\nLocation: $LOCATION\nX-RunArt-Canary: $CANARY\nX-RunArt-Resolver: $RESOLVER"
echo -e "$SUMMARY"

if echo "$STATUS" | grep -q "200" && [[ -n "$CANARY" && -n "$RESOLVER" ]]; then
  exit 0
else
  exit 1
fi
