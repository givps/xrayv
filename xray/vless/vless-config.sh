#!/bin/bash
# =========================================
# Generate vless-config.json
# =========================================

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /etc/xray/config/vless.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10112,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 10002,
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "${uuid}"
#vlessws
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless-ws"
        }
      },
      "tag": "vlessws"
    },
    {
      "listen": "127.0.0.1",
      "port": 10012,
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "${uuid}"
#vlessgrpc
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vless-grpc"
        }
      },
      "tag": "vlessgrpc"
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
wget -O add-vless "https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/add-vless.sh" && chmod +x add-vless
wget -O trial-vless "https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/trial-vless.sh" && chmod +x trial-vless
wget -O renew-vless "https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/cek-vless.sh" && chmod +x cek-vless
wget -O m-vless "https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/m-vless.sh" && chmod +x m-vless
cd
