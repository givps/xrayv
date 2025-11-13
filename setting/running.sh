#!/bin/bash
# =========================================
# Check VPS Services Status
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m          SERVICES STATUS           \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

check_status() {
    systemctl is-active --quiet $1
    if [ $? -eq 0 ]; then
        echo -e " [$1] \e[32mRUNNING\e[0m"
    else
        echo -e " [$1] \e[31mSTOPPED\e[0m"
    fi
}

services=("nginx" "xray")

for service in "${services[@]}"; do
    check_status $service
done

echo ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to return to menu"
menu
