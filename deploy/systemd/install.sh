#!/usr/bin/env bash
# Sample systemd debian install script for reference.
set -euo pipefail

ACTING_USER="personal-site"
SITE_DIR="/var/www/requef.com"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTS_DIR"

if ! id -u "$ACTING_USER" >/dev/null 2>&1; then
    echo "Creating user and group $ACTING_USER"
    adduser --system --group "$ACTING_USER"
fi

echo "Installing update.sh to /usr/local/libexec/personal-site/"
install -d -o root -g root -m 755 /usr/local/libexec/personal-site
install -o root -g root -m 755 "$SCRIPTS_DIR/../update.sh" /usr/local/libexec/personal-site/update.sh

echo "Installing personal-site-update.service and personal-site-update.timer to /etc/systemd/system/"
install -o root -g root -m 644 ./personal-site-update.service ./personal-site-update.timer /etc/systemd/system/

echo "Creating site directory $SITE_DIR"
install -d -o "$ACTING_USER" -g "$ACTING_USER" -m 755 "$SITE_DIR"

echo "Installed, do daemon-reload and enable the service"
