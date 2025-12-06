# Server Performance Stats

A bash script to analyse basic Linux server performance statistics.

## Features

The script provides detailed system performance insights, including:

### **System Information**
- Hostname
- Operating system version
- Kernel version
- System architecture
- Uptime

### **Load Averages**
- 1-minute load
- 5-minute load
- **10-minute synthetic load** (calculated from 5 & 15 min averages)
- 15-minute load
- Alerts if the 10-minute load exceeds CPU core count

### **CPU Metrics**
- Total CPU usage (from top)
- Number of CPU cores
- Alerts if CPU usage exceeds 80%

### **Memory Metrics**
- Total memory
- Used memory (MiB + percentage)
- Free memory (MiB + percentage)
- Alerts if memory usage exceeds 80%

### **Disk Usage**
- Root filesystem usage
- Total disk usage across all filesystems
- Alerts if root filesystem is above 80%

### **Process Monitoring**
- Top 5 processes by memory usage
- Top 5 processes by CPU usage

### **User & Network Information**
- Logged-in users
- IPv4 addresses per network interface
- Listening TCP ports (via ss/netstat)

---

## 🚀 Getting Started

1. **Clone this repository:**

  ```bash
  git clone https://github.com/KOvacevNS/DevOps-RoadMap.git
  ```
  ```bash
  cd server-performance-stats
  ```
2.  **Make the script executable**

  ```bash
  chmod +x server-stats.sh
  ```
3. **Execute the script**
   
  ```bash
  ./server-stats.sh
  ```
This is part of [roadmap.sh](https://roadmap.sh/projects/server-stats) DevOps projects.
