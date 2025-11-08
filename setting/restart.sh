#!/bin/bash
# =========================================
# RESTART MENU
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m          RESTART MENU           \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m1\e[0m] Restart All Services"
echo -e " [\e[36m2\e[0m] Restart Nginx"
echo -e " [\e[36m3\e[0m] Restart Xray"
echo -e ""
echo -e " [\e[31m0\e[0m] \e[31mBack To Menu\033[0m"
echo -e ""
echo -e "Press x or [ Ctrl+C ]  To-Exit"
echo -e ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""

read -p " Select menu : " Restart
echo ""

case $Restart in
1)
    echo -e "\e[32mRestarting Nginx...\e[0m"
    systemctl restart nginx
    echo -e "\e[32mRestarting Xray...\e[0m"
    systemctl restart xray
    echo -e "\e[32mAll services restarted successfully!\e[0m"
    sleep 2
    $0
    ;;
2)
    echo -e "\e[32mRestarting Nginx...\e[0m"
    systemctl restart nginx
    echo -e "\e[32mNginx restarted successfully!\e[0m"
    sleep 2
    $0
    ;;
3)
    echo -e "\e[32mRestarting Xray...\e[0m"
    systemctl restart xray
    echo -e "\e[32mXray restarted successfully!\e[0m"
    sleep 2
    $0
    ;;
0)
    clear
    m-system
    ;;
x|X)
    exit
    ;;
*)
    echo -e "\e[31mInvalid option! Please select again.\e[0m"
    sleep 1
    $0
    ;;
esac
