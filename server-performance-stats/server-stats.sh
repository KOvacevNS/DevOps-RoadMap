#!/usr/bin/env bash

# server-stats.sh - simple health check

# Alert collors
if [ -t 1 ]; then
  RED="\033[0;31m"
  YELLOW="\033[0;33m"
  NC="\033[0m" # no color
else
  RED=""
  YELLOW=""
  NC=""
fi

echo 
echo ################################# Basic System Info #################################
echo "Hostname:  $(hostname)"
echo "OS:        $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"')"
echo "Kernel:    $(uname -r)"
echo "Arch:      $(uname -m)"

echo
echo ################################# System Uptime Info #################################
uptime

echo
echo ################################# Load Averages #################################
if [ -r /proc/loadavg ]; then
  LOAD1=$(awk '{print $1}' /proc/loadavg)
  LOAD5=$(awk '{print $2}' /proc/loadavg)
  LOAD15=$(awk '{print $3}' /proc/loadavg)

  # Calculate a synthetic 10 minutes load, average 5-15min
  LOAD10=$(awk -v l5="$LOAD5" -v l15="$LOAD15" 'BEGIN { printf "%.2f", (l5 + l15) / 2 }')

  echo "1 min  : $LOAD1"
  echo "5 min  : $LOAD5"
  echo "10 min : $LOAD10"
  echo "15 min : $LOAD15"

  # Warning if 10 minutes load exceeds number of CPU cores
  if command -v nproc >/dev/null 2>&1; then
    CORES=$(nproc)

    # Compare as integers *10 to avoid float compare issues
    LOAD10x10=$(awk -v l10="$LOAD10" 'BEGIN { printf "%d", l10 * 10 }')
    CORESx10=$((CORES * 10))

    if [ "$LOAD10x10" -gt "$CORESx10" ]; then
      echo -e "${RED}ALERT: 10-minute load ($LOAD10) exceeds the number of CPU cores ($CORES)!${NC}"
    fi
  fi
else
  echo "N/A"
fi

echo
echo ################################# Total CPU Usage #################################
if command -v top >/dev/null 2>&1; then
  CPU_USAGE_RAW=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')
  # Fallback if parsing fails
  if [ -z "$CPU_USAGE_RAW" ]; then
    echo "Usage: N/A (could not parse from top)"
  else
    CPU_USAGE_INT=${CPU_USAGE_RAW%.*}
    echo "Usage: ${CPU_USAGE_RAW}%"
    if [ "$CPU_USAGE_INT" -ge 80 ] 2>/dev/null; then
      echo -e "${RED}ALERT: High CPU usage!${NC}"
    fi
  fi
else
  echo "top command not available."
fi

echo
echo ################################# CPU Cores #################################
if command -v nproc >/dev/null 2>&1; then
  echo "Cores: $(nproc)"
else
  echo "Cores: N/A (nproc not available)"
fi

echo
echo ################################# Total Memory Usage #################################
read -r MEM_TOTAL MEM_USED MEM_FREE <<<"$(free -m | awk '/Mem:/ {print $2, $3, $4}')"

MEM_USED_PCT=$(( MEM_USED * 100 / MEM_TOTAL ))
MEM_FREE_PCT=$(( MEM_FREE * 100 / MEM_TOTAL ))

printf "Total: %d MiB\n" "$MEM_TOTAL"
printf "Used : %d MiB (%d%%)\n" "$MEM_USED" "$MEM_USED_PCT"
printf "Free : %d MiB (%d%%)\n" "$MEM_FREE" "$MEM_FREE_PCT"

if [ "$MEM_USED_PCT" -ge 80 ]; then
  echo -e "${RED}WARNING: High memory usage!${NC}"
fi

ech0
echo ################################# Total Disk Usage #################################
echo "# Root filesystem (/):"
df -h / | awk 'NR==2 {printf "Size : %s\nUsed : %s (%s)\nAvail: %s\n", $2, $3, $5, $4}'

ROOT_USED_PCT=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
if [ "$ROOT_USED_PCT" -ge 80 ] 2>/dev/null; then
  echo -e "${RED}WARNING: Root filesystem usage high!${NC}"
fi

echo
echo "# All filesystems (summary):"
df -h --total | tail -1 | awk '{printf "Total Size : %s\nTotal Used : %s (%s)\nTotal Avail: %s\n", $2, $3, $5, $4}'

echo
echo ################################# Top 5 Processes by Memory Usage #################################
printf "USER\tPID\t%%MEM\tCOMMAND\n"
ps aux --sort=-%mem | head -n 6 | awk 'NR>1 {print $1 "\t" $2 "\t" $4 "\t" $11}'

echo
echo ################################# Top 5 Processes by CPU Usage #################################
printf "USER\tPID\t%%CPU\tCOMMAND\n"
ps aux --sort=-%cpu | head -n 6 | awk 'NR>1 {print $1 "\t" $2 "\t" $3 "\t" $11}'

echo
echo ################################# Logged-in Users #################################
if who | grep -q .; then
  who
else
  echo "No users currently logged in."
fi

echo
echo ################################# Network Interfaces #################################
if command -v ip >/dev/null 2>&1; then
  ip -4 addr show | awk '/inet / {print $2 " on " $NF}'
else
  echo "ip command not available."
fi

echo
echo ################################# Listening TCP Ports #################################
if command -v ss >/dev/null 2>&1; then
  ss -tuln | awk 'NR==1 || /LISTEN/'
elif command -v netstat >/dev/null 2>&1; then
  netstat -tuln | awk 'NR==1 || /LISTEN/'
else
  echo "Neither ss nor netstat available."
fi

echo
echo "Done"
