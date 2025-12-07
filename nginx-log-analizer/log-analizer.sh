#!/usr/bin/env bash

set -e              #-exit on error
set -u              #-treat unset variables as errors
set -o pipefail     #-fail pipelines if any command fails

# Colors
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
NC="\033[0m"

LOG_FILE="${1:-}"

if [ -z "$LOG_FILE" ]; then
    echo "Usage: $0 <access-log-file>"
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found."
    exit 1
fi

echo "======================================="
echo " Top 5 IP addresses"
echo "======================================="
awk '{print $1}' "$LOG_FILE" \
  | sort | uniq -c | sort -nr | head -5

echo
echo "======================================="
echo " Top 5 requested paths"
echo "======================================="
awk -F\" '{print $2}' "$LOG_FILE" \
  | awk '{print $2}' \
  | sort | uniq -c | sort -nr | head -5

echo
echo "======================================="
echo " Top 5 response status codes"
echo " (404 & 500 = red, 304 = yellow, others = green)"
echo "======================================="

awk '{print $9}' "$LOG_FILE" \
  | sort | uniq -c | sort -nr | head -5 \
  | while read -r count code; do
        [ -z "${code:-}" ] && continue

        if [ "$code" = "404" ] || [ "$code" = "500" ]; then
            color="$RED"
        elif [ "$code" = "304" ]; then
            color="$YELLOW"
        else
            color="$GREEN"
        fi

        printf "%5s %b%s%b\n" "$count" "$color" "$code" "$NC"
    done

echo
echo "======================================="
echo " Top 5 user agents"
echo "======================================="
awk -F\" '{print $6}' "$LOG_FILE" \
  | sort | uniq -c | sort -nr | head -5

echo
echo "======================================="
echo " Top 10 paths returning 404"
echo "======================================="

# just lines with status 404, get path
awk '$9 == 404 {print $0}' "$LOG_FILE" \
  | awk -F\" '{print $2}' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -nr | head -10 \
  | while read -r count path; do
        printf "%5s %b404%b %s\n" "$count" "$RED" "$NC" "$path"
    done

echo
echo "======================================="
echo " Top 10 paths returning 500"
echo "======================================="

# just lines with status 500, get path
awk '$9 == 500 {print $0}' "$LOG_FILE" \
  | awk -F\" '{print $2}' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -nr | head -10 \
  | while read -r count path; do
        printf "%5s %b500%b %s\n" "$count" "$RED" "$NC" "$path"
    done
