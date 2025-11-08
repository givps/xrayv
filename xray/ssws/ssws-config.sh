#!/bin/bash
# =========================================
# Generate ssws-config.json
# =========================================

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /etc/xray/config/ssws.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10114,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 10004,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
          {
            "method": "aes-128-gcm",
            "password": "${uuid}"
#ssws
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ss-ws"
        }
      },
      "tag": "ssws"
    },
    {
      "listen": "127.0.0.1",
      "port": 10014,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
          {
            "method": "aes-128-gcm",
            "password": "${uuid}"
#ssgrpc
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "ss-grpc"
        }
      },
      "tag": "ssgrpc"
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
wget -O add-ssws "https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/add-ssws.sh" && chmod +x add-ssws
wget -O trial-ssws "https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/trial-ssws.sh" && chmod +x trial-ssws
wget -O renew-ssws "https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/renew-ssws.sh" && chmod +x renew-ssws
wget -O del-ssws "https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/del-ssws.sh" && chmod +x del-ssws
wget -O cek-ssws "https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/cek-ssws.sh" && chmod +x cek-ssws
wget -O m-ssws "https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/m-ssws.sh" && chmod +x m-ssws
cd
