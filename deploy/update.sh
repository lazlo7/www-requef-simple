#!/usr/bin/env bash
set -euo pipefail

[[ -n "${WORKING_DIR:-}" ]] || { echo "Error: WORKING_DIR environment variable is not set" >&2; exit 1; }

OWNER='lazlo7'
REPO='www-requef-simple'
LAST_RELEASES_TO_KEEP=5

cd "$WORKING_DIR"

echo "Checking out new release for $OWNER/$REPO"
latest_release=$(curl -fsSL "https://api.github.com/repos/$OWNER/$REPO/releases/latest")
asset_count=$(jq '.assets | length' <<< "$latest_release")
if [[ "$asset_count" -ne 1 ]]; then
    echo "Error: Expected exactly one asset in the latest release, but found $asset_count" >&2
    exit 1
fi

site_tag_name=$(jq -r '.tag_name' <<< "$latest_release")
echo "Latest release tag: $site_tag_name"
if [[ -L current ]]; then
    current_tag_name=$(basename "$(readlink current)")
    echo "Current release tag: $current_tag_name"
    if [[ "$current_tag_name" = "$site_tag_name" ]]; then
        echo "Tags are equivalent - no need to update"
        exit 0
    else
        echo "Tags are different - updating to new release"
    fi
fi

site_url=$(jq -r '.assets[0].browser_download_url' <<< "$latest_release")
echo "Downloading release $site_url"
site_digest=$(jq -r '.assets[0].digest' <<< "$latest_release")

curl -fsSLo site.tar.gz "$site_url"
got_digest=$(sha256sum site.tar.gz | awk '{print $1}')
if [[ "sha256:$got_digest" != "$site_digest" ]]; then
    echo "Error: sha256 checksum mismatch for site.tar.gz" >&2
    echo "Expected $site_digest, but got $got_digest" >&2
    exit 1
fi

mkdir -p "release/$site_tag_name"
echo "Unpacking release $site_tag_name"
tar -C "release/$site_tag_name" --strip-components=1 -xf site.tar.gz
rm site.tar.gz

echo "Updating the current symlink"
ln -s "release/$site_tag_name" .current.next
mv -Tf .current.next current

echo "Cleaning up old releases"
find release -mindepth 1 -maxdepth 1 -type d -printf '%T@\t%p\n' | sort -n | cut -f2- | head -n-$LAST_RELEASES_TO_KEEP | xargs -r rm -rf
