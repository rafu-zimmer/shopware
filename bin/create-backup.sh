#!/usr/bin/env bash

set -e

BASE_DIR="/var/www/vhosts/rafu.de"
BIN_DIR="$BASE_DIR/httpdocs/bin"
CURR_VER=$(/opt/plesk/php/8.0/bin/php "$BIN_DIR/console" --version | grep -oP "6\\.\d+\\.\d+\\.\d+")
BACKUP_DIR="$BASE_DIR/backup/$CURR_VER"

# Ensure backup directory for current version exists
mkdir -p "$BACKUP_DIR"

# Copy media assets
cd "$BASE_DIR/httpdocs/public" && zip -FS -9 -r "$BACKUP_DIR/media.zip" media

# Create db-dump
mysqldump -ushopware -pG4rm5e59~ shopware > "$BACKUP_DIR/backup.sql"
