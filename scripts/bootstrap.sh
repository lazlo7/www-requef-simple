#!/usr/bin/env bash
set -euo pipefail

ASSETS_VERSION='v1'
ASSETS_SHA256='75f7f59784c9ede948a0fe0a392242ea44b662230621a1fa8de7f5f317c9d94d'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASSETS_FILENAME="assets-$ASSETS_VERSION.tar.gz"
ASSETS_URL="https://github.com/lazlo7/www-requef-simple-assets/releases/download/$ASSETS_VERSION/$ASSETS_FILENAME"
curl -fsSLo "$ASSETS_FILENAME" "$ASSETS_URL"
if ! echo "$ASSETS_SHA256  $ASSETS_FILENAME" | sha256sum -c --status; then
    echo "Error: sha256 checksum mismatch for $ASSETS_FILENAME" >&2
    exit 1
fi

ASSETS_DIR="$SCRIPTS_DIR/../src/assets"
tar -C "$ASSETS_DIR" --strip-components=1 -xf "$ASSETS_FILENAME"
rm "$ASSETS_FILENAME"
echo "Assets unpacked to $ASSETS_DIR"
