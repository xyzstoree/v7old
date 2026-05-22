#!/bin/bash
# kyt.sh — installer bot kyt
# FIX #25: scope find ke /usr/bin/kyt/ saja (bukan seluruh /usr/bin)

NS=$(cat /etc/xray/dns 2>/dev/null)
PUB=$(cat /etc/slowdns/server.pub 2>/dev/null)
domain=$(cat /etc/xray/domain 2>/dev/null)

grenbo="\e[92;1m"
NC='\e[0m'

apt update -y && apt upgrade -y
apt install -y python3 python3-pip git python3-venv unzip

cd /usr/bin || exit 1

# Bot files
wget -q -O /tmp/bot.zip "https://raw.githubusercontent.com/xyzstoree/v7old/main/limit/bot.zip"
unzip -q -o /tmp/bot.zip -d /tmp/bot.tmp
mv -f /tmp/bot.tmp/bot/* /usr/bin/ 2>/dev/null
chmod +x /usr/bin/* 2>/dev/null
rm -rf /tmp/bot.zip /tmp/bot.tmp

# Kyt files
clear
wget -q -O /tmp/kyt.zip "https://raw.githubusercontent.com/xyzstoree/v7old/main/limit/kyt.zip"
unzip -q -o /tmp/kyt.zip -d /usr/bin
rm -f /tmp/kyt.zip

python3 -m venv /usr/bin/kyt/venv
# shellcheck disable=SC1091
source /usr/bin/kyt/venv/bin/activate
pip install --quiet -r /usr/bin/kyt/requirements.txt
deactivate

if [ ! -f /usr/bin/kyt/var.txt ]; then
    echo
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " \e[1;97;101m          ADD BOT PANEL          \e[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "${grenbo}Tutorial Create Bot and ID Telegram${NC}"
    echo -e "${grenbo}[*] Create Bot and Token Bot : @BotFather${NC}"
    echo -e "${grenbo}[*] Info Id Telegram : @MissRose_bot , command /info${NC}"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -e -rp "[*] Input your Bot Token : " bottoken
    read -e -rp "[*] Input Your Id Telegram :" admin

    {
        echo "BOT_TOKEN=\"$bottoken\""
        echo "ADMIN=\"$admin\""
        echo "DOMAIN=\"$domain\""
        echo "PUB=\"$PUB\""
        echo "HOST=\"$NS\""
    } > /usr/bin/kyt/var.txt
    chmod 600 /usr/bin/kyt/var.txt
else
    echo "Using existing bot configuration from var.txt"
    bottoken=$(grep 'BOT_TOKEN' /usr/bin/kyt/var.txt | cut -d'=' -f2 | tr -d '"')
    admin=$(grep 'ADMIN' /usr/bin/kyt/var.txt | cut -d'=' -f2 | tr -d '"')
    domain=$(grep 'DOMAIN' /usr/bin/kyt/var.txt | cut -d'=' -f2 | tr -d '"')
    PUB=$(grep 'PUB' /usr/bin/kyt/var.txt | cut -d'=' -f2 | tr -d '"')
    NS=$(grep 'HOST' /usr/bin/kyt/var.txt | cut -d'=' -f2 | tr -d '"')
fi
clear

# FIX #25: scope hapus session ke /usr/bin/kyt/ saja
echo "Deleting old session files..."
find /usr/bin/kyt -type f -name "*.session" -exec rm -f {} \;

cat > /etc/systemd/system/kyt.service <<END
[Unit]
Description=Simple kyt - @kyt
After=network.target

[Service]
WorkingDirectory=/usr/bin
ExecStart=/usr/bin/kyt/venv/bin/python3 -m kyt
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable --now kyt
systemctl restart kyt

rm -f /root/kyt.sh

echo "Done"
echo "Your Data Bot"
echo "==============================="
echo "Token Bot         : $bottoken"
echo "Admin             : $admin"
echo "Domain            : $domain"
echo "Pub               : $PUB"
echo "Host              : $NS"
echo "==============================="
echo "Setting done"
clear
echo "Installations complete, type /menu on your bot"
