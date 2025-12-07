# Log Archive Tool

A small Bash utility for safely archiving and cleaning up log files.

The script compresses log files from a given directory into a timestamped `tar.gz` archive, removes only the files that were successfully archived, and rotates old archives (older than 6 months).

---

## Features

  - Archives log files from a directory (default: `/var/log`)
  - Creates compressed archives in an `archives/` directory (relative to where the script is run)
  - Archive naming format:

  ```text
  logs_archive_YYYYMMDD_HHMMSS.tar.gz
  ```

Deletes only the files that were actually archived
Logs each archive operation to archive.log
Rotates old archives: removes .tar.gz archives older than 180 days (≈ 6 months)
Uses safe Bash options (set -e, set -u, set -o pipefail)

## Requirements

-Bash
-GNU tar
-find, date, rm, wc

## Installation

Save the script as log-archive (or any name you prefer).

Make it executable:
```bash
chmod +x log-archive
```

Move it to a directory in your $PATH f.e.:
```bash
sudo mv log-archive /usr/local/bin/
```

## Usage

Basic usage (default /var/log)
```bash
./log-archive
```

or, if installed in $PATH:
```bash
log-archive
```

Custom log directory
```bash
./log-archive /path/to/logs
```

Examples:
```bash
./log-archive /var/log
./log-archive /opt/myapp/logs
```

## What the script does (step by step)

### 1. Selects log directory

  - If an argument is provided, uses that as LOG_DIR
  - Otherwise defaults to /var/log
  - Exits with an error if the directory does not exist

### 2. Collects files to archive

Uses find to collect only regular files at depth 1:
```bash
find "$LOG_DIR" -maxdepth 1 -type f
```

If no files are found, exits with:
```text
No log files to archive.
```

### 3. Prepares archive directory

Creates ./archives if it doesn’t exist
```bash
mkdir -p "$ARCHIVE_DIR"
```

### 4. Creates the archive

Builds a timestamped name, e.g.:
```text
logs_archive_xxxxxxxx_xxxxxx.tar.gz
```

Uses tar to archive exactly the collected files:
```bash
tar -czf "$ARCHIVE_FILE" -C "$LOG_DIR" $(basename -a $FILE_LIST)
```

### 5. Deletes only archived files

Iterates over the previously collected list and removes each file:
```bash
rm -f "$f"
```

  - This ensures it does not delete anything that wasn’t part of the archive.

### 6. Logs the operation

Appends a line to archive.log, e.g.:
```text
xxxx-xx-xx xx:xx:xx archived /var/log to ./archives/logs_archive_xxxxxxx_xxxxxx.tar.gz
```

### 7. Rotates old archives

Removes .tar.gz files under ./archives older than 180 days:
```bash
find "$ARCHIVE_DIR" -maxdepth 1 -type f -mtime +180 -name "*.tar.gz" -delete
```

## Automation with cron

To run the script automatically on the 1st of every month at 03:00, edit your crontab:
```bash
crontab -e
```

Add:
```bash
0 3 1 * * /path/to/log-archive >> /path/to/log-archive-cron.log 2>&1
```

If the script is in your $PATH (e.g. /usr/local/bin/log-archive):
```bash
0 3 1 * * log-archive >> /var/log/log-archive-cron.log 2>&1
```

This is part of [roadmap.sh](https://roadmap.sh/projects/server-stats) DevOps projects.
