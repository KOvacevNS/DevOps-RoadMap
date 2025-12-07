#!/usr/bin/env bash

set -e              #-exit on error
set -u              #-treat unset variables as errors
set -o pipefail     #-fail pipelines if any command fails

# Use /var/log by default
LOG_DIR="${1:-/var/log}"
[ -d "$LOG_DIR" ] || { echo "Directory '$LOG_DIR' not found"; exit 1; }

# Collect only regular files for safe archiving
FILE_LIST=$(find "$LOG_DIR" -maxdepth 1 -type f)
[ -z "$FILE_LIST" ] && { echo "No log files to archive."; exit 0; }

# Prepare archive directory
ARCHIVE_DIR="./archives"
mkdir -p "$ARCHIVE_DIR"

# Add timestamp
TS=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_FILE="$ARCHIVE_DIR/logs_archive_${TS}.tar.gz"

# Archive exactly collected files
tar -czf "$ARCHIVE_FILE" -C "$LOG_DIR" $(basename -a $FILE_LIST)

# Delete only archived files
for f in $FILE_LIST; do rm -f "$f"; done

# Log the action
echo "$(date +"%Y-%m-%d %H:%M:%S") archived $LOG_DIR to $ARCHIVE_FILE" >> archive.log

# Rotate archives older than 6 months (180 days)
find "$ARCHIVE_DIR" -maxdepth 1 -type f -mtime +180 -name "*.tar.gz" -delete

echo "Archived $(echo "$FILE_LIST" | wc -l) files to $ARCHIVE_FILE."
echo "Rotation complete: archives older than 6 months removed."
