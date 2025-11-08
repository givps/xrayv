#!/bin/bash
# =========================================
# Generate trojan-config.json
# =========================================

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /etc/xray/config/trojan.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10111,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 10001,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}"
#trojanws
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan-ws"
        }
      },
      "tag": "trojan-ws"
    },
    {
      "listen": "127.0.0.1",
      "port": 10011,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}"
#trojangrpc
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "trojan-grpc"
        }
      },
      "tag": "trojan-grpc"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "blocked"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "inboundTag": ["api"],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      }
    ]
  },
  "api": {
    "tag": "api",
    "services": ["StatsService"]
  },
  "stats": {},
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
EOF

cd /usr/bin/
wget -O add-trojan "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/add-trojan.sh" && chmod +x add-trojan
wget -O renew-trojan "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/renew-trojan.sh" && chmod +x renew-trojan
wget -O trial-trojan "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/trial-trojan.sh" && chmod +x trial-trojan
wget -O del-trojan "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/del-trojan.sh" && chmod +x del-trojan
wget -O cek-trojan "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/cek-trojan.sh" && chmod +x cek-trojan
wget -O m-trojan "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/m-trojan.sh" && chmod +x m-trojan
wget -O xpxray "https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/xpxray.sh" && chmod +x xpxray
cd

cat > /etc/cron.d/xpxray_otm <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xpxray
EOF
