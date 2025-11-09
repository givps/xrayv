#!/bin/bash
# =========================================
# cek trojan ws grpc
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
echo -n > /tmp/other.txt
data=( `cat /usr/local/etc/xray/config.json | grep '^##' | cut -d ' ' -f 2`);
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m        trojan user login          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
for user in "${data[@]}"
do
if [[ -z "$user" ]]; then
user="not found"
fi
echo -n > /tmp/iptrojan.txt
data2=( `netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | awk '{print $5}' | cut -d: -f1 | sort | uniq`);
for ip in "${data2[@]}"
do
access=$(cat /var/log/xray/access.log | grep -w $user | awk '{print $3}' | cut -d: -f1 | grep -w $ip | sort | uniq)
if [[ "$access" = "$ip" ]]; then
echo "$access" >> /tmp/iptrojan.txt
else
echo "$ip" >> /tmp/other.txt
fi
access2=$(cat /tmp/iptrojan.txt)
sed -i "/$access2/d" /tmp/other.txt > /dev/null 2>&1
done
access=$(cat /tmp/iptrojan.txt)
if [[ -z "$access" ]]; then
echo > /dev/null
else
access2=$(cat /tmp/iptrojan.txt | nl)
echo "user : $user";
echo "$access2";
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi
rm -f /tmp/iptrojan.txt
done
oth=$(cat /tmp/other.txt | sort | uniq | nl)
echo "other";
echo "$oth";
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
rm -f /tmp/other.txt
read -n 1 -s -r -p "Press any key to back on menu"
m-trojan
