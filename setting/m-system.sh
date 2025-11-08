#!/bin/bash
# =========================================
# SYSTEM MENU
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m        SYSTEM MENU           \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m1\e[0m] Panel Domain"
echo -e " [\e[36m2\e[0m] Speedtest VPS"
echo -e " [\e[36m3\e[0m] Set Auto Reboot"
echo -e " [\e[36m4\e[0m] Restart All Service"
echo -e " [\e[36m5\e[0m] Cek Bandwith"
echo -e " [\e[36m6\e[0m] DNS CHANGER"
echo -e ""
echo -e " [\e[31m0\e[0m] \e[31mBack To Menu\033[0m"
echo -e   ""
echo -e   "Press x or [ Ctrl+C ]  To-Exit"
echo -e   ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; m-domain ; exit ;;
2) clear ; speedtest ; exit ;;
3) clear ; auto-reboot ; exit ;;
4) clear ; restart ; exit ;;
5) clear ; bw ; exit ;;
6) clear ; m-dns ; exit ;;
0) clear ; menu ; exit ;;
x) exit ;;
*) echo "You pressed it wrong" ; sleep 1 ; m-system ;;
esac
