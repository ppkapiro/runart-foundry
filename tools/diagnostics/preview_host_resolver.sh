#!/usr/bin/env bash
set -e
BRANCH=$(git rev-parse --abbrev-ref HEAD | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
HOST_BRANCH="${BRANCH}.runart-foundry.pages.dev"
BASE_HOST="runart-foundry.pages.dev"

check_dns() {
  host -W 2 "$1" >/dev/null 2>&1 && echo true || echo false
}

check_http() {
  curl -sI --max-time 3 --head --location --output /dev/null --write-out "%{http_code}" "https://$1/" 2>/dev/null | grep -qE "^(2|3)" && echo true || echo false
}

BRANCH_DNS_OK=$(check_dns "$HOST_BRANCH")
BASE_DNS_OK=$(check_dns "$BASE_HOST")

BRANCH_HTTP_OK=$(check_http "$HOST_BRANCH")
BASE_HTTP_OK=$(check_http "$BASE_HOST")

jq -n --arg branch "$BRANCH" --arg host_branch "$HOST_BRANCH" \
      --argjson branch_dns_ok "$BRANCH_DNS_OK" --argjson base_dns_ok "$BASE_DNS_OK" \
      --argjson branch_http_ok "$BRANCH_HTTP_OK" --argjson base_http_ok "$BASE_HTTP_OK" \
      '{branch: $branch, host_branch: $host_branch, branch_dns_ok: $branch_dns_ok, base_dns_ok: $base_dns_ok, branch_http_ok: $branch_http_ok, base_http_ok: $base_http_ok}'
