#!/bin/bash
# =========================================
# Shadowsocks Account
# =========================================
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m       Shadowsocks Account           \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m1\e[0m] Create Account Shadowsocks "
echo -e " [\e[36m2\e[0m] Create Trial Shadowsocks "
echo -e " [\e[36m3\e[0m] Extending Account Shadowsocks "
echo -e " [\e[36m4\e[0m] Delete Account Shadowsocks "
echo -e " [\e[36m5\e[0m] Check User Login Shadowsocks "
echo -e " [\e[36m6\e[0m] User list created Account "
echo -e ""
echo -e " [\e[31m0\e[0m] \e[31mBack To Menu\033[0m"
echo -e   ""
echo -e   "Press x or [ Ctrl+C ]  To-Exit"
echo ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; add-ssws ;;
2) clear ; trial-ssws ;;
3) clear ; renew-ssws ;;
4) clear ; del-ssws ;;
5) clear ; cek-ssws ;;
6) clear ; cat /var/log/xray/ssws.log ; exit ;;
0) clear ; menu ;;
x) exit ;;
*) echo "You pressed it wrong" ; sleep 1 ; m-ssws ;;
esac
