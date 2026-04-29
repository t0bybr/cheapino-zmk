#!/usr/bin/env bash
# Fetch latest ZMK firmware UF2 from GitHub Actions artifact.
#
# Usage:
#   scripts/fetch-firmware.sh                  # latest success on current branch
#   scripts/fetch-firmware.sh <RUN_ID>         # specific run id
#   scripts/fetch-firmware.sh --latest         # latest run regardless of status
#
# Requires: curl, jq, unzip. Token in ~/tmp/gh (first line).

set -euo pipefail

TOKEN_FILE="${HOME}/tmp/gh"
OUT_DIR="${TMPDIR:-/tmp}/zmk-fw"

if [[ ! -r "$TOKEN_FILE" ]]; then
    echo "error: token file not found at $TOKEN_FILE" >&2
    exit 1
fi
TOKEN=$(head -n1 "$TOKEN_FILE" | tr -d '[:space:]')

for cmd in curl jq unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "error: missing dependency: $cmd" >&2
        exit 1
    fi
done

REMOTE=$(git -C "$(dirname "$0")/.." remote get-url origin)
REPO=$(echo "$REMOTE" | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?$|\1|; s|\.git$||')
BRANCH=$(git -C "$(dirname "$0")/.." rev-parse --abbrev-ref HEAD)

API="https://api.github.com/repos/$REPO"
AUTH_HEADER="Authorization: Bearer $TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github+json"

# Determine RUN_ID
case "${1:-}" in
    "")
        echo "fetching latest successful run on branch '$BRANCH' ..." >&2
        RUN_ID=$(curl -fsS -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
            "$API/actions/runs?per_page=1&status=success&branch=$BRANCH" \
            | jq -r '.workflow_runs[0].id // empty')
        if [[ -z "$RUN_ID" ]]; then
            echo "error: no successful runs found on '$BRANCH'" >&2
            exit 2
        fi
        ;;
    --latest)
        echo "fetching latest run on '$BRANCH' (any status) ..." >&2
        RUN_ID=$(curl -fsS -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
            "$API/actions/runs?per_page=1&branch=$BRANCH" \
            | jq -r '.workflow_runs[0].id // empty')
        ;;
    *)
        RUN_ID="$1"
        ;;
esac

# Show run metadata
RUN_META=$(curl -fsS -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" "$API/actions/runs/$RUN_ID")
SHA=$(echo "$RUN_META" | jq -r '.head_sha[:7]')
TITLE=$(echo "$RUN_META" | jq -r '.display_title')
STATUS=$(echo "$RUN_META" | jq -r '.conclusion // .status')
echo "run $RUN_ID  ($STATUS)  $SHA  $TITLE" >&2

# Get artifact
ARTIFACT_ID=$(curl -fsS -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
    "$API/actions/runs/$RUN_ID/artifacts" \
    | jq -r '.artifacts[0].id // empty')
if [[ -z "$ARTIFACT_ID" ]]; then
    echo "error: no artifacts on run $RUN_ID" >&2
    exit 3
fi

ZIP="$OUT_DIR/firmware-$RUN_ID.zip"
mkdir -p "$OUT_DIR"
echo "downloading artifact $ARTIFACT_ID ..." >&2
curl -fsSL -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
    -o "$ZIP" \
    "$API/actions/artifacts/$ARTIFACT_ID/zip"

rm -f "$OUT_DIR"/*.uf2
unzip -oq "$ZIP" -d "$OUT_DIR"

UF2=$(ls "$OUT_DIR"/*.uf2 2>/dev/null | head -n1)
if [[ -z "$UF2" ]]; then
    echo "error: no .uf2 file in artifact" >&2
    exit 4
fi

echo "$UF2"
