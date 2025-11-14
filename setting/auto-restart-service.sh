cat > /usr/bin/advanced-monitor.sh <<'EOF'
#!/bin/bash
# Advanced VPS Service Monitor & Auto-Restart
# Services to monitor
SERVICES=("xray" "nginx")
LOG_FILE="/var/log/advanced-monitor.log"

# System thresholds
MAX_CPU=80        # max CPU usage (%) before restart
MAX_MEM=90        # max memory usage (%) before restart

# Function: log message
log_msg() {
    echo "$(date '+%F %T') - $1" | tee -a "$LOG_FILE"
}

# Check each service
for S in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$S"; then
        log_msg "$S is down. Restarting..."
        systemctl restart "$S"
        sleep 2
        if systemctl is-active --quiet "$S"; then
            log_msg "$S restarted successfully."
        else
            log_msg "Failed to restart $S!"
        fi
    fi
done

# Check CPU usage
CPU_USAGE=$(top -bn1 | awk '/Cpu/ {print int($2+$4)}')
if [ "$CPU_USAGE" -ge "$MAX_CPU" ]; then
    log_msg "High CPU usage detected: ${CPU_USAGE}%. Restarting services..."
    for S in "${SERVICES[@]}"; do
        systemctl restart "$S"
    done
fi

# Check memory usage
MEM_USAGE=$(free | awk '/Mem/ {printf("%d", $3/$2 * 100)}')
if [ "$MEM_USAGE" -ge "$MAX_MEM" ]; then
    log_msg "High Memory usage detected: ${MEM_USAGE}%. Restarting services..."
    for S in "${SERVICES[@]}"; do
        systemctl restart "$S"
    done
fi
EOF

chmod +x /usr/bin/advanced-monitor.sh
echo "*/5 * * * * root /usr/bin/advanced-monitor.sh" > /etc/cron.d/advanced-monitor
