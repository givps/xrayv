# install

- 1
```
apt update && apt upgrade -y && apt autoremove -y && reboot
```
- 2
```
apt update && apt install -y bzip2 gzip coreutils screen curl unzip && wget https://raw.githubusercontent.com/givps/xrayv/master/setup.sh && chmod +x setup.sh && sed -i -e 's/\r$//' setup.sh && screen -S setup ./setup.sh
```
