#!/usr/bin/env bash

# Make sure we are able to access the forwarded ssh-auth-sock (store previous value)
PERMISSIONS=$(stat -c "%a" "$SSH_AUTH_SOCK")
sudo chmod 777 "${SSH_AUTH_SOCK}"

# Pre-save known hosts
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts 2> /dev/null
ssh-keyscan github.com >> ~/.ssh/known_hosts 2> /dev/null

# Get project root (copied from bin/build.sh)
BIN_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
export PROJECT_ROOT="${PROJECT_ROOT:-"$(dirname "$BIN_DIR")"}"

# Do the update!
composer update -d "${PROJECT_ROOT}" --no-interaction

# Restore original permissions on ssh-auth-sock
sudo chmod "$PERMISSIONS" "${SSH_AUTH_SOCK}"
