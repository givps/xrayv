#!/bin/bash
# =========================================
# Generate vmess-config.json
# =========================================

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /etc/xray/config/vmess.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10113,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 10003,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#vmessws
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess-ws"
        }
      },
      "tag": "vmessws"
    },
    {
      "listen": "127.0.0.1",
      "port": 10013,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#vmessgrpc
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vmess-grpc"
        }
      },
      "tag": "vmessgrpc"
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
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "api"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
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
wget -q -O add-vmess "https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/add-vmess.sh" && chmod +x add-vmess
wget -q -O trial-vmess "https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/trial-vmess.sh" && chmod +x trial-vmess
wget -q -O renew-vmess "https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/renew-vmess.sh" && chmod +x renew-vmess
wget -q -O del-vmess "https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/del-vmess.sh" && chmod +x del-vmess
wget -q -O cek-vmess "https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/cek-vmess.sh" && chmod +x cek-vmess
wget -q -O m-vmess "https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/m-vmess.sh" && chmod +x m-vmess
cd
