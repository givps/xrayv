#!/bin/bash
# =========================================
# Check Trojan WS & gRPC Active Logins
# =========================================
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================

clear
TMP_OTHER="/tmp/other.txt"
TMP_IPTROJAN="/tmp/iptrojan.txt"
LOG_XRAY="/var/log/xray/access.log"
CONF_XRAY="/usr/local/etc/xray/config.json"

> "$TMP_OTHER"

# Ambil daftar user dari marker #1
mapfile -t data < <(grep -E "^[[:space:]]*#1 " "/usr/local/etc/xray/config.json" | awk '{print $2}')

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m        Trojan Active Users        \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

for user in "${data[@]}"; do
    [[ -z "$user" ]] && continue
    > "$TMP_IPTROJAN"

    # Ambil IP aktif dari xray
    mapfile -t data2 < <(netstat -anp 2>/dev/null | grep ESTABLISHED | grep tcp6 | grep xray | awk '{print $5}' | cut -d: -f1 | sort -u)

    for ip in "${data2[@]}"; do
        if grep -qw "$ip" <(grep -w "$user" "$LOG_XRAY" | awk '{print $3}' | cut -d: -f1); then
            echo "$ip" >> "$TMP_IPTROJAN"
        else
            echo "$ip" >> "$TMP_OTHER"
        fi
    done

    access=$(sort -u "$TMP_IPTROJAN")
    if [[ -n "$access" ]]; then
        echo -e "${GREEN}User:${NC} $user"
        echo "$access" | nl
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    fi
done

# tampilkan ip yang tidak cocok user
if [[ -s "$TMP_OTHER" ]]; then
    echo -e "${RED}Other Connections:${NC}"
    sort -u "$TMP_OTHER" | nl
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi

rm -f "$TMP_OTHER" "$TMP_IPTROJAN"

echo ""
read -n 1 -s -r -p "Press any key to return to menu..."
m-trojan
