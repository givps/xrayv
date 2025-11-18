# disable connect ip vps port 443 & 80 from public / connect only with subdomain proxy using cloudflare
iptables -D INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null
iptables -D INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null

for i in {1..5}; do
    iptables -D INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null
    iptables -D INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null
done

for ip in $(curl -s https://www.cloudflare.com/ips-v4); do
    iptables -A INPUT -p tcp -s $ip --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp -s $ip --dport 443 -j ACCEPT
done

iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 443 -j DROP

iptables -D INPUT 6

apt install iptables-persistent -y
netfilter-persistent save
netfilter-persistent reload

reboot
