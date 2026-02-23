# Server Performance Stats

> A Bash script to analyse basic server performance stats.

## Table of Contents

* [General Info](#general-information)
* [Setup](#setup)
* [Usage](#usage)
* [Project Status](#project-status)
* [Acknowledgements](#acknowledgements)

## General Information

This is a Bash script that can analyse basic server performance stats on Linux, such as total CPU, memory, and disk usage. It can also display information about the top 5 processes by CPU or memory usage.

## Setup

To run this script, you’ll need the following pre-installed commands:

* mpstat
* free
* df
* ps
* w
* last

How to run:

1. Clone the repository

   ```bash
   git clone https://github.com/krisnaajiep/server-performance-stats.git
   ```

2. Change the current working directory

   ```bash
   cd server-performance-stats
   ```

3. Add the execute permission to the script

   ```bash
   chmod +x server-stats.sh
   ```

4. Execute the script

   ```bash
   ./server-stats.sh
   ```

## Usage

```bash
Usage: ./server-stats.sh [options]
Options:
    cpu            Show total CPU usage
    mem            Show total memory usage
    disk           Show total disk usage
    proc [cpu|mem] Show top 5 process by cpu and memory usage
    auth           Show logged in users and bad login attempts
    -h, --help     Show this help message and exit
```

Example output:

```bash
Current date and time       : Sun Feb 22 10:13:29 PM WIB 2026
Hostname                    : server1
Operating System            : Ubuntu 24.04.4 LTS
Kernel version              : 6.17.0-14-generic
System uptime               : up 1 week, 1 day, 1 hour, 58 minutes
Load average (1, 5, 15 min) : 0.29, 0.86, 1.18

Collecting server stats...

Total CPU Usage:
--------------------------------------------------------------------------------
ALL        : 8.01%
CPU1       : 8.42%
CPU2       : 10.2%
CPU3       : 6.19%
CPU4       : 7.22%

Total Memory Usage:
--------------------------------------------------------------------------------
Total      : 31Gi
Used       : 12Gi (38.71%)
Free       : 2.4Gi
Available  : 18Gi

Total Disk Usage:
--------------------------------------------------------------------------------
Total      : 496G
Used       : 218G (47%)
Available  : 255G

Top 5 Processes by CPU Usage:
--------------------------------------------------------------------------------
    PID COMMAND         %CPU
1711099 chrome           300
1710957 chrome          18.0
1285756 VirtualBoxVM    10.9
1710956 chrome           4.8
1515458 code             4.6

Top 5 Processes by Memory Usage:
--------------------------------------------------------------------------------
    PID COMMAND         %MEM
1285756 VirtualBoxVM     7.5
3963985 gnome-system-mo  4.8
3946117 chrome           2.2
1075241 chrome           1.9
3946565 chrome           1.8

Logged in users: 1
--------------------------------------------------------------------------------
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
user1    tty2     -                14Feb26  8days  2:11m  0.04s /usr/libexec/gnome-session-binary --session=ubuntu

Bad login attempts: 1
--------------------------------------------------------------------------------
user1     seat0        login screen     Fri Feb  6 05:56 - 05:56  (00:00)

btmp begins Fri Feb  6 05:56:54 2026
```

Note: if you need root permission to read `/var/log/btmp` file for bad login attempts, run the script as root.

```bash
sudo ./server-stats.sh
```

## Project Status

Project is: _complete_.

## Acknowledgements

This project was inspired by [roadmap.sh](https://roadmap.sh/projects/server-stats).
