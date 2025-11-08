#!/bin/bash
# ==========================================
# install xray & ssl
# ==========================================
# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
nc='\e[0m'

# Get domain
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
mkdir -p /myinfo
country=$(curl -s https://api.country.is 2>/dev/null | jq -r '.country' 2>/dev/null)
if [[ -z "$country" || "$country" == "null" ]]; then
    country=$(curl -s https://ipinfo.io/json 2>/dev/null | jq -r '.country' 2>/dev/null)
fi
if [[ -z "$country" || "$country" == "null" ]]; then
    country="API limit..."
fi
mkdir -p /myinfo
echo "$country" | tee /myinfo/country > /dev/null

# Install all packages in one command (more efficient)
echo -e "[ ${green}INFO${nc} ] Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y \
    iptables iptables-persistent \
    curl python3 socat xz-utils wget apt-transport-https \
    gnupg gnupg2 gnupg1 dnsutils lsb-release \
    cron bash-completion \
    zip pwgen openssl netcat

# Clean up packages
apt clean && apt autoremove -y > /dev/null

# Create directory if doesn't exist and set permissions
rm -f /usr/local/bin/xray
mkdir -p /usr/local/bin /usr/local/etc/xray /var/log/xray
touch /var/log/xray/{access,error}.log
id xray &>/dev/null || useradd -r -s /usr/sbin/nologin xray
# xray official
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u xray
xray version
# Set ownership
chmod +x /usr/local/bin/xray
chown -R root:root /usr/local/bin/xray
chown -R xray:xray /usr/local/etc/xray
chown -R xray:xray /var/log/xray

# nginx stop
systemctl stop nginx

LOG_FILE="/var/log/acme-setup.log"
mkdir -p /var/log
rm -rf /root/.acme.sh
rm -f /usr/local/etc/xray/xray.crt
rm -f /usr/local/etc/xray/xray.key
# Rotate log if >1MB
[ -f "$LOG_FILE" ] && [ "$(stat -c%s "$LOG_FILE")" -gt 1048576 ] && {
  ts=$(date +%Y%m%d-%H%M%S)
  mv "$LOG_FILE" "$LOG_FILE.$ts.bak"
  ls -tp /var/log/acme-setup.log.*.bak 2>/dev/null | tail -n +4 | xargs -r rm --
}

exec > >(tee -a "$LOG_FILE") 2>&1

# ---------- Dependencies ----------
echo -e "[${blue}INFO${nc}] Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y curl wget socat cron openssl bash >/dev/null 2>&1

# ---------- Domain ----------
domain=$(cat /usr/local/etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
[[ -z "$domain" ]] && echo -e "${red}[ERROR] Domain file not found!${nc}" && exit 1

# ---------- Cloudflare Token ----------
DEFAULT_CF_TOKEN="XCu7wHsxlkbcU3GSPOEvl1BopubJxA9kDcr-Tkt8"
read -rp "Enter Cloudflare API Token (ENTER for default): " CF_Token
export CF_Token="${CF_Token:-$DEFAULT_CF_TOKEN}"

# ---------- Retry helper ----------
retry() { local n=1; until "$@"; do ((n++==5)) && exit 1; echo -e "${yellow}Retry $n...${nc}"; sleep 3; done; }

# ---------- Install acme.sh ----------
ACME_HOME="/root/.acme.sh"
if [ ! -f "$ACME_HOME/acme.sh" ]; then
  echo -e "[${green}INFO${nc}] Installing acme.sh official..."
  curl https://get.acme.sh | sh
fi

# Reload ACME_HOME
export ACME_HOME="/root/.acme.sh"

# ---------- Ensure Cloudflare DNS hook ----------
mkdir -p "$ACME_HOME/dnsapi"
[ ! -f "$ACME_HOME/dnsapi/dns_cf.sh" ] && wget -qO "$ACME_HOME/dnsapi/dns_cf.sh" https://raw.githubusercontent.com/acmesh-official/acme.sh/master/dnsapi/dns_cf.sh && chmod +x "$ACME_HOME/dnsapi/dns_cf.sh"

# ---------- Register ACME account ----------
echo -e "[${green}INFO${nc}] Registering ACME account..."
retry bash "$ACME_HOME/acme.sh" --register-account -m ssl@ipgivpn.my.id --server letsencrypt

# ---------- Issue wildcard certificate ----------
echo -e "[${blue}INFO${nc}] Issuing wildcard certificate for ${domain}..."
retry bash "$ACME_HOME/acme.sh" --issue --dns dns_cf -d "$domain" -d "*.$domain" --force --server letsencrypt

# ---------- Install certificate ----------
echo -e "[${blue}INFO${nc}] Installing certificate..."
mkdir -p /usr/local/etc/xray
retry bash "$ACME_HOME/acme.sh" --installcert -d "$domain" \
  --fullchainpath /usr/local/etc/xray/xray.crt \
  --keypath /usr/local/etc/xray/xray.key

# ---------- Auto-renew cron ----------
cat > /etc/cron.d/acme-renew <<EOF
0 3 1 */2 * root $ACME_HOME/acme.sh --cron --home $ACME_HOME > /var/log/acme-renew.log 2>&1
EOF
chmod 644 /etc/cron.d/acme-renew

# ---------- Done ----------
echo -e "[${green}SUCCESS${nc}] ACME.sh + Cloudflare setup completed!"
echo -e "CRT: /usr/local/etc/xray/xray.crt"
echo -e "KEY: /usr/local/etc/xray/xray.key"

mkdir -p /etc/xray/config
wget -qO- https://raw.githubusercontent.com/givps/xrayv/master/xray/ssws/ssws-config.sh | bash
wget -qO- https://raw.githubusercontent.com/givps/xrayv/master/xray/vless/vless-config.sh | bash
wget -qO- https://raw.githubusercontent.com/givps/xrayv/master/xray/vmess/vmess-config.sh | bash
wget -qO- https://raw.githubusercontent.com/givps/xrayv/master/xray/trojan/trojan-config.sh | bash

chown -R xray:xray /etc/xray/config
chmod -R 755 /etc/xray/config
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Config Service
After=network.target nss-lookup.target

[Service]
User=xray
ExecStart=/usr/local/bin/xray run -confdir /etc/xray/config
Restart=on-failure
RestartPreventExitStatus=23
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start xray
systemctl enable xray
systemctl restart xray

cat >/etc/nginx/conf.d/xray.conf <<'EOF'
server {
    listen 80;
    server_name _;

    location = /trojan-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /vless-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /vmess-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10003;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /ss-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10004;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }
}

server {
    listen 443 ssl http2 reuseport;
    server_name _;

    ssl_certificate /usr/local/etc/xray/xray.crt;
    ssl_certificate_key /usr/local/etc/xray/xray.key;
    ssl_ciphers ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_protocols TLSv1.2 TLSv1.3;

    location = /trojan-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /vless-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /vmess-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10003;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location = /ss-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10004;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }

    location ^~ /trojan-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $http_host;
        grpc_pass grpc://127.0.0.1:10011;
    }

    location ^~ /vless-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $http_host;
        grpc_pass grpc://127.0.0.1:10012;
    }

    location ^~ /vmess-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $http_host;
        grpc_pass grpc://127.0.0.1:10013;
    }

    location ^~ /ss-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP $remote_addr;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        grpc_set_header Host $http_host;
        grpc_pass grpc://127.0.0.1:10014;
    }
}
EOF

systemctl daemon-reload
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
