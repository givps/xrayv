#!/bin/bash
# =========================================
# auto delete xray user expired
# =========================================
#----- Auto Remove Trojan
for u in $(grep '^##' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  [[ $(date -d "$exp" +%s) -le $(date +%s) ]] && \
  sed -i "/^## $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
done

#----- Auto Remove Vless
for u in $(grep '^###' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  [[ $(date -d "$exp" +%s) -le $(date +%s) ]] && \
  sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
done

##----- Auto Remove Vmess
for u in $(grep '^####' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  [[ $(date -d "$exp" +%s) -le $(date +%s) ]] && \
  sed -i "/^#### $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
done

##----- Auto Remove Shadowsocks
for u in $(grep '^#####' /usr/local/etc/xray/config.json | awk '{print $2,$3}'); do
  user=$(echo $u | awk '{print $1}')
  exp=$(echo $u | awk '{print $2}')
  [[ $(date -d "$exp" +%s) -le $(date +%s) ]] && \
  sed -i "/^##### $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
done
systemctl restart xray-trojan >/dev/null 2>&1
