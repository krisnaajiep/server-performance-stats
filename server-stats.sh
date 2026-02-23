#!/usr/bin/env bash

set -euo pipefail

if [[ "${TRACE:-0}" -eq 1 ]]
then
    set -x
fi

# Print help message
help_message() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  cpu            Show total CPU usage"
    echo "  mem            Show total memory usage"
    echo "  disk           Show total disk usage"
    echo "  proc [cpu|mem] Show top 5 process by cpu and memory usage"
    echo "  auth           Show logged in users and bad login attempts"
    echo "  -h, --help     Show this help message and exit"
}

if [[ "${1:-}" =~ ^-*h(elp)?$ ]]
then
    help_message
    exit 0
fi

printf -v strip "%*s" 80 ""

require_cmd() {
    command -v "$1" > /dev/null 2>&1 || {
        echo "Error: '$1' command is required but not installed."
        exit 1
    }
}

dependency_check() {
    require_cmd mpstat
    require_cmd free
    require_cmd df
    require_cmd ps
    require_cmd hostnamectl
    require_cmd w
}

# Print additional host information
init() {
    local hostnamectl="$(hostnamectl)"
    
    printf "%-27s %-1s %s\n" "Current date and time" ":" "$(date)"
    printf "%-27s %-1s %s\n" "Hostname" ":" "$(echo "$hostnamectl" | awk -F': ' ' /Static hostname:/ {print $2}')"
    printf "%-27s %-1s %s\n" "Operating System" ":" "$(echo "$hostnamectl" | awk -F': ' ' /Operating System:/ {print $2}')"
    printf "%-27s %-1s %s\n" "Kernel version" ":" "$(echo "$hostnamectl" | awk -F': ' ' /Kernel:/ {print $2}')"
    printf "%-27s %-1s %s\n" "System uptime" ":" "$(uptime -p)"
    printf "%-27s %-1s %s\n" "Load average (1, 5, 15 min)" ":" "$(uptime | awk -F'load average: ' '{print $2}')"

    printf "\n%s\n" "Collecting server stats..."
}


# Print total CPU usage
total_cpu_usage() {
    local summary="$(mpstat -P ALL 1 1 | tail -n +4 | awk '!/Average:/ && $1 != "" {print}')"
    
    printf "\n%s\n" "Total CPU Usage:"
    echo "${strip// /-}"
    
    while IFS= read -r line
    do
        local cpu=$(echo "$line" | awk '{print $3}')
        local usage=$(echo "$line" | awk '{print 100 - $NF}')

        if [[ "$cpu" == "all" ]]; then
            cpu=${cpu^^}  # Convert to uppercase
        else
            cpu="CPU$(( cpu + 1 ))"
        fi
        
        printf "%-10s %-1s %s\n" "$cpu" ":" "$usage%"
    done <<< "$summary"
}

# Print total memory usage
total_memory_usage() {
    local mem_info="$(free -h)"
    local total="$(echo "$mem_info" | awk '/Mem:/ {print $2}')"
    local used="$(echo "$mem_info" | awk '/Mem:/ {print $3}')"
    local free="$(echo "$mem_info" | awk '/Mem:/ {print $4}')"
    local available="$(echo "$mem_info" | awk '/Mem:/ {print $7}')"
    local used_percentage="$(free | awk '/Mem:/ {printf("%.2f", $3/$2 * 100)}')"
    local cache="$(echo "$mem_info" | awk '/Mem:/ {print $6}')"

    printf "\n%s\n" "Total Memory Usage:"
    echo "${strip// /-}"

    printf "%-10s %-1s %s\n" "Total" ":" "$total"
    printf "%-10s %-1s %s\n" "Used" ":" "$used ($used_percentage%)"
    printf "%-10s %-1s %s\n" "Free" ":" "$free"
    printf "%-10s %-1s %s\n" "Total" ":" "$total"
    printf "%-10s %-1s %s\n" "Available" ":" "$available"
}


# Print total disk usage
total_disk_usage() {
    local disk_info="$(df -h --total | tail -n 1)"
    local total="$(echo "$disk_info" | awk '{print $2}')"
    local used="$(echo "$disk_info" | awk '{print $3}')"
    local available="$(echo "$disk_info" | awk '{print $4}')"
    local used_percentage="$(df --total | tail -n 1 | awk '{print $5}')"

    printf "\n%s\n" "Total Disk Usage:"
    echo "${strip// /-}"

    printf "%-10s %-1s %s\n" "Total" ":" "$total"
    printf "%-10s %-1s %s\n" "Used" ":" "$used ($used_percentage)"
    printf "%-10s %-1s %s\n" "Available" ":" "$available"
}

# Print top 5 processes by CPU or Memory usage
top_5_processes() {
    if [[ "${1:-}" == "cpu" ]]
    then
        top_5_processes_by_cpu
    elif [[ "${1:-}" == "mem" ]]
    then
        top_5_processes_by_memory
    else
        top_5_processes_by_cpu
        top_5_processes_by_memory
    fi
}

# Print top 5 processes by CPU usage
top_5_processes_by_cpu() {
    printf "\n%s\n" "Top 5 Processes by CPU Usage:"
    echo "${strip// /-}"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
}

# Print top 5 processes by Memory usage
top_5_processes_by_memory() {
    printf "\n%s\n" "Top 5 Processes by Memory Usage:"
    echo "${strip// /-}"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6
}

# Print logged in users and failed login attempts"
auth_logs() {
    local logged_in_users="$(w)"
    local bad_login_attempts

    printf "\n%s\n" "Logged in users: $(echo "$logged_in_users" | tail -n +3 | wc -l)"
    echo "${strip// /-}"
    echo "$logged_in_users" | tail -n +2

    if command -v lastb > /dev/null && [[ -r /var/log/btmp ]]; then
        bad_login_attempts="$(lastb)"
        printf "\n%s\n" "Bad login attempts: $(echo "$bad_login_attempts" | head -n -2 | wc -l)"
    else
        printf "\n%s\n" "Bad login attempts:"
        bad_login_attempts="Permission denied or unavailable"
    fi

    echo "${strip// /-}"
    echo "$bad_login_attempts"
}

# Print all stats
all_stats() {
    total_cpu_usage
    total_memory_usage
    total_disk_usage
    top_5_processes_by_cpu
    top_5_processes_by_memory
    auth_logs
}

main() {
    dependency_check
    init

    # Collect server stats
    if [[ "$#" -ge 1 ]]
    then
        case "$1" in
            cpu)
                total_cpu_usage
                ;;
            mem)
                total_memory_usage
                ;;
            disk)
                total_disk_usage
                ;;
            proc)
                shift
                top_5_processes "$@"
                ;;
            auth)
                auth_logs
                ;;
            *)
                printf "\n%s\n" "$0: invalid option"
                help_message
                ;;
        esac
    else
        all_stats
    fi
}

main "$@"