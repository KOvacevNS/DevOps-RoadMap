# Nginx Log Analyzer

A simple Bash-based log analysis tool for extracting useful metrics from Nginx access logs.

The script parses standard Nginx "combined" log format and generates summaries such as:

- Top IP addresses
- Top requested paths
- Top response status codes (with color highlighting)
- Top user agents
- Top 10 paths returning **404** (highlighted in red)
- Top 10 paths returning **500** (highlighted in red)

Designed as part of the roadmap.sh DevOps learning path.

---

## Features

### ✔ Top 5 IP addresses  
Counts how many requests each IP made.

### ✔ Top 5 requested paths  
Extracts HTTP paths such as `/api/v1/status` and ranks them.

### ✔ Top 5 response status codes  
With color coding:

- **Red** → 404 and 500  
- **Yellow** → 304  
- **Green** → all other 2xx/3xx codes

### ✔ Top 5 user agents  
Helps identify bots, crawlers, or application clients.

### ✔ Top 10 paths returning 404  
Shows which URLs users/bots are requesting but do not exist.

### ✔ Top 10 paths returning 500  
Useful for troubleshooting server errors.

---

## Requirements

The script uses common Linux tools:

- `awk`
- `grep`
- `sort`
- `uniq`
- `head`

All available by default on any Linux system or WSL on Windows.

---

## Installation

Clone your repository:
```bash
git clone <your-repo-url>
cd nginx-log-analyzer
```

## Make the script executable:
```bash
chmod +x log-analyzer.sh
```

## Usage

Run the script and pass your log file as an argument:
```bash
./log-analyzer.sh access.log
```
## Color Legend
```text
Status	    Meaning	              Color
404	        Not Found	            🔴 Red
500	        Server Error	        🔴 Red
304	        Not Modified	        🟡 Yellow
Other	      Success / Redirect	  🟢 Green
```
