#!/bin/bash
# =========================================
# del ssws ws grpc
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
NUMBER_OF_CLIENTS=$(grep -c -E "^##### " "/etc/xray/config/ssws.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m   delete shadowsocks account  \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "You have no existing client"
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
m-ssws
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m   delete shadowsocks account  \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "  User   Expired  " 
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E "^##### " "/etc/xray/config/ssws.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
echo ""
echo -e "  • [NOTE] Press any key to back on menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "Input Username : " user
if [ -z $user ]; then
m-ssws
else
exp=$(grep -wE "^##### $user" "/etc/xray/config/ssws.json" | cut -d ' ' -f 3 | sort | uniq)
sed -i "/^##### $user $exp/,/^},{/d" /etc/xray/config/ssws.json
systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m   delete shadowsocks account  \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "   • Accound delete success"
echo -e ""
echo -e "   • Client Name : $user"
echo -e "   • Expired On  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-ssws
fi
