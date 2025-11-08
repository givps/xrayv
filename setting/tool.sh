#!/bin/bash
# =========================================
# install ssh tool
# =========================================

# Colors
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
cyan='\e[1;36m'
white='\e[1;37m'
nc='\e[0m'

# Update system first
apt update -y

# Remove unused or conflicting firewall/mail services
systemctl stop ufw 2>/dev/null
systemctl disable ufw 2>/dev/null
apt-get remove --purge -y ufw firewalld exim4

# Install base system tools and network utilities
apt install -y \
  shc wget curl figlet ruby python3 make cmake \
  iptables iptables-persistent netfilter-persistent \
  coreutils rsyslog net-tools htop screen \
  zip unzip nano sed gnupg bc jq bzip2 gzip \
  apt-transport-https build-essential dirmngr \
  libxml-parser-perl neofetch git lsof iftop \
  libsqlite3-dev libz-dev gcc g++ libreadline-dev \
  zlib1g-dev libssl-dev dos2unix

# Install Ruby gem (colorized text)
gem install lolcat

# Enable and start logging service
systemctl enable rsyslog
systemctl start rsyslog

# Configure vnstat for network monitoring
if ! command -v vnstat &> /dev/null; then
    apt install -y vnstat
fi
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)
mkdir -p /var/lib/vnstat
chown vnstat:vnstat /var/lib/vnstat
if [ ! -f "/var/lib/vnstat/$INTERFACE" ]; then
    vnstat -u -i "$INTERFACE"
fi
systemctl daemon-reload
systemctl enable vnstat
systemctl restart vnstat

# Create secure PAM configuration
#wget -q -O /etc/pam.d/common-password "https://raw.githubusercontent.com/givps/AutoScriptXraoy/master/ssh/password"
#chmod +x /etc/pam.d/common-password

# reload iptables
cat > /etc/rc.local <<'EOF'
#!/bin/sh -e
netfilter-persistent reload
exit 0
EOF
chmod +x /etc/rc.local

cat > /etc/systemd/system/rc-local.service <<'EOF'
[Unit]
Description=/etc/rc.local compatibility
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable rc-local
systemctl start rc-local

# disable ipv6
grep -qxF 'net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf || echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
grep -qxF 'net.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf || echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf

sysctl -p

# Remove old NGINX
apt purge -y nginx nginx-common nginx-core nginx-full
apt remove -y nginx nginx-common nginx-core nginx-full
apt autoremove -y

# Install Nginx
apt update -y && apt install -y nginx

# Remove default configs
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
rm -f /usr/share/nginx/html/index.html
rm -f /etc/nginx/conf.d/default.conf
rm -f /etc/nginx/conf.d/vps.conf

# Download custom configs
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/givps/xrayv/master/ssh/nginx.conf"

# Add systemd override (fix for early startup)
mkdir -p /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf

# Restart Nginx
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx

# Setup web root directory
#wget -q -O /usr/share/nginx/html/index.html "https://raw.githubusercontent.com/givps/xrayv/master/ssh/index"

# setup sshd
cat > /etc/ssh/sshd_config <<EOF
Port 22
Port 2222
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
PubkeyAuthentication yes
AllowTcpForwarding yes
PermitTTY yes
X11Forwarding no
TCPKeepAlive yes
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
MaxStartups 10:30:100
UsePAM yes
ChallengeResponseAuthentication no
UseDNS no
Compression delayed
GSSAPIAuthentication no
SyslogFacility AUTH
LogLevel INFO
EOF

systemctl restart sshd
systemctl enable sshd

# install fail2ban
apt -y install fail2ban

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
banaction = iptables-multiport
backend = auto

[sshd]
enabled  = true
port     = 22,2222
filter   = sshd
backend = systemd
maxretry = 3
findtime = 600
bantime  = 3600

[sshd-ddos]
enabled  = true
port = 22,2222
filter = sshd
backend = systemd
maxretry = 5
findtime = 300
bantime = 604800

[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
action = iptables-allports[name=recidive, protocol=all]
bantime = 1209600
findtime = 86400
maxretry = 5
EOF

systemctl daemon-reload
systemctl enable fail2ban
systemctl start fail2ban

# Instal DDOS Deflate
#wget -qO- https://raw.githubusercontent.com/givps/xrayv/master/ssh/auto-install-ddos.sh | bash

# install blokir torrent
#wget -qO- https://raw.githubusercontent.com/givps/xrayv/master/ssh/auto-torrent-blocker.sh | bash

# download script
cd /usr/bin
# menu
wget -O menu "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/menu.sh"
wget -O running "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/running.sh"
wget -O clearcache "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/clearcache.sh"
# menu system
wget -O m-system "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/m-system.sh"
wget -O m-domain "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/m-domain.sh"
wget -O crt "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/crt.sh"
wget -O auto-reboot "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/auto-reboot.sh"
wget -O restart "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/restart.sh"
wget -O bw "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/bw.sh"
wget -O m-dns "https://raw.githubusercontent.com/givps/xrayv/master/xray/setting/m-dns.sh"

chmod +x menu
chmod +x running
chmod +x clearcache
chmod +x m-system
chmod +x m-domain
chmod +x crt
chmod +x auto-reboot
chmod +x restart
chmod +x bw
chmod +x m-dns

# Install speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
apt-get install -y speedtest || true

systemctl enable cron
systemctl start cron

# remove unnecessary files
apt autoclean -y >/dev/null 2>&1

if dpkg -s unscd >/dev/null 2>&1; then
apt -y remove --purge unscd >/dev/null 2>&1
fi

apt-get -y --purge remove samba* >/dev/null 2>&1
apt-get -y --purge remove apache2* >/dev/null 2>&1
apt-get -y --purge remove bind9* >/dev/null 2>&1
apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
