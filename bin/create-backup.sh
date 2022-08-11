#!/usr/bin/env bash

set -e

cd ~

BASE_DIR="$(pwd)/httpdocs"
BIN_DIR="${BASE_DIR}/bin"
CURR_VER=$(/opt/plesk/php/8.0/bin/php "${BIN_DIR}/console" --version | grep -oP "6\\.\d+\\.\d+\\.\d+")
BACKUP_DIR="$(pwd)/backup/${CURR_VER}"

# Ensure backup directory for current version exists
mkdir -p "${BACKUP_DIR}"

# Zip media assets into backup dir
cd "${BASE_DIR}/public" && zip -FS -9 -r "${BACKUP_DIR}/media.zip" media


### Create db-dump
## Check for column-statistics option
_COLUMN_STATISTICS=
if mysqldump --help | grep "\-\-column-statistics" > /dev/null; then
_COLUMN_STATISTICS="--column-statistics=0"
fi

## Load shopware .env-file
export $(cat ${BASE_DIR}/.env | xargs)

## Get db connection info
[[ -z "${DATABASE_URL}" ]] && echo "Error: ENV var DATABASE_URL must not be empty (should be set inside shopware's .env-file)" && exit 1

regex="mysql:\/\/([^:]*):([^@]*)@([^:]*):([^\/]*)\/(.*)"
[[ "${DATABASE_URL}" =~ $regex ]]
DB_USER="${BASH_REMATCH[1]}"
DB_PASS="${BASH_REMATCH[2]}"
DB_HOST="${BASH_REMATCH[3]}"
DB_PORT="${BASH_REMATCH[4]}"
DB_DATABASE="${BASH_REMATCH[5]}"

# Generate create-info
mysqldump ${_COLUMN_STATISTICS} --no-tablespaces --quick -C --hex-blob --single-transaction --no-data -u${DB_USER} -p${DB_PASS} ${DB_DATABASE} | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' > "${BACKUP_DIR}/backup.sql"

# Generate data
mysqldump --no-tablespaces --quick -C --hex-blob --single-transaction --no-create-info --skip-triggers -u${DB_USER} -p${DB_PASS} ${DB_DATABASE} --ignore-table=${DB_DATABASE}.enqueue --ignore-table=${DB_DATABASE}.product_keyword_dictionary --ignore-table=${DB_DATABASE}.product_search_keyword | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' >> "${BACKUP_DIR}/backup.sql"
