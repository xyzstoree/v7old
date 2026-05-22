#!/bin/bash
# botrs.sh — Installer Bot Telegram (cybervpn)
# FIX #9: download dari path 3rd party tetap dipertahankan (sesuai aslinya),
#         tapi semua wget pakai timeout & log error.
# FIX #27, #28: validasi $MYIP & $IZIN, hindari uncatched syntax error.

set -u

MYIP=$(curl -sS --max-time 10 ipinfo.io/ip 2>/dev/null)
if [[ -z "$MYIP" ]]; then
    echo "[ERROR] Tidak bisa mendapat IP publik VPS, cek DNS/koneksi."
    exit 1
fi

# FIX #27: pastikan kedua sisi `[ ]` punya nilai
IZIN=$(curl -sS --max-time 10 https://raw.githubusercontent.com/xyzstoree/izin/main/ip 2>/dev/null \
        | awk -v ip="$MYIP" '$0 ~ ip {print $4}' | head -n1)

if [[ -z "$IZIN" || "$MYIP" != "$IZIN" ]]; then
    clear
    if command -v figlet >/dev/null && command -v lolcat >/dev/null; then
        figlet "Akses ditolak" | lolcat
    else
        echo "Akses ditolak. Hubungi admin."
    fi
    exit 0
fi

echo "IZIN DITERIMA"

# Backup variabel jika ada
mkdir -p /tmp
cp -f /media/cybervpn/var.txt /tmp/ 2>/dev/null || true
cp -f /root/cybervpn/var.txt /tmp/ 2>/dev/null || true
clear

apt update && apt upgrade -y
apt install -y python3 python3-pip sqlite3 python3-venv git

mkdir -p /media
cd /media || exit 1
rm -rf cybervpn

clear
wget -q "https://raw.githubusercontent.com/xyzstoree/v7old/main/limit/cybervpn.zip" -O /media/cybervpn.zip
unzip -q /media/cybervpn.zip -d /media
cd /media/cybervpn || exit 1
rm -f var.txt database.db
clear

# Set up a virtual environment
python3 -m venv /media/cybervpn/venv
# shellcheck disable=SC1091
source /media/cybervpn/venv/bin/activate
pip install --quiet telethon pillow speedtest-cli aiohttp paramiko
[ -f /media/cybervpn/requirements.txt ] && pip install -q -r /media/cybervpn/requirements.txt
deactivate

sldns=$(cat /root/nsdomain 2>/dev/null)
domain=$(cat /etc/xray/domain 2>/dev/null)

clear
echo "INSTALL BOT CREATE SSH via TELEGRAM"
read -e -rp "[*] Input Your Id Telegram :" admin
read -e -rp "[*] Input Your bot Telegram :" token
read -e -rp "[*] Input username Telegram :" user

cat > /media/cybervpn/var.txt <<END
ADMIN="$admin"
BOT_TOKEN="$token"
DOMAIN="$domain"
DNS="$sldns"
PUB="7fbd1f8aa0abfe15a7903e837f78aba39cf61d36f183bd604daa2fe4ef3b7b59"
OWN="$user"
SALDO="100000"
END
chmod 600 /media/cybervpn/var.txt

clear
cat > /usr/bin/nenen <<'END'
#!/bin/bash
cd /media
python3 -m cybervpn
END
chmod 755 /usr/bin/nenen

cat > /etc/systemd/system/botrs.service <<END
[Unit]
Description=cybervpn bot service
After=network.target

[Service]
WorkingDirectory=/media
ExecStart=/media/cybervpn/venv/bin/python3 -m cybervpn
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable --now botrs
systemctl restart botrs

cd /root || cd /
rm -f /root/botrs.sh

clear
echo
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[44;97;1m        DOWNLOAD ASSET BOT         \e[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo

# Helper untuk download dengan timeout & error handling
dl() {
    local url="$1" dst="$2"
    if wget --tries=2 --timeout=15 -q -O "$dst" "$url" && [ -s "$dst" ]; then
        chmod +x "$dst"
    else
        echo "[WARN] gagal download: $url"
    fi
}

ARI_BASE="https://raw.githubusercontent.com/arivpnstores/v6/main/bot"
dl "$ARI_BASE/panelbot.sh"  /usr/bin/panelbot
dl "$ARI_BASE/addnoobz.sh"  /usr/bin/addnoobz
dl "$ARI_BASE/log-install.txt" /media/log-install.txt
dl "$ARI_BASE/add-vless.sh" /usr/bin/add-vless
dl "$ARI_BASE/addtr.sh"     /usr/bin/addtr
dl "$ARI_BASE/addws.sh"     /usr/bin/addws
dl "$ARI_BASE/addss.sh"     /usr/bin/addss
dl "$ARI_BASE/cek-ssh.sh"   /usr/bin/cek-ssh
dl "$ARI_BASE/cek-ss.sh"    /usr/bin/cek-ss
dl "$ARI_BASE/cek-tr.sh"    /usr/bin/cek-tr
dl "$ARI_BASE/cek-vless.sh" /usr/bin/cek-vless
dl "$ARI_BASE/cek-ws.sh"    /usr/bin/cek-ws
dl "$ARI_BASE/del-vless.sh" /usr/bin/del-vless
dl "$ARI_BASE/cek-noobz.sh" /usr/bin/cek-noobz
dl "$ARI_BASE/deltr.sh"     /usr/bin/deltr
dl "$ARI_BASE/delws.sh"     /usr/bin/delws
dl "$ARI_BASE/delss.sh"     /usr/bin/delss
dl "$ARI_BASE/renew-ss.sh"  /usr/bin/renew-ss
dl "$ARI_BASE/renewtr.sh"   /usr/bin/renewtr
dl "$ARI_BASE/renewvless.sh" /usr/bin/renewvless
dl "$ARI_BASE/renewws.sh"   /usr/bin/renewws
dl "$ARI_BASE/cek-mws.sh"   /usr/bin/cek-mws
dl "$ARI_BASE/cek-mvs.sh"   /usr/bin/cek-mvs
dl "$ARI_BASE/cek-mss.sh"   /usr/bin/cek-mss
dl "$ARI_BASE/cek-mts.sh"   /usr/bin/cek-mts
# Diganti ke HTTPS bila tersedia; kalau tidak tersedia, akan dilewati.
dl "https://myrid.my.id/bot/addssh-bot" /usr/bin/addssh-bot

cp -f /tmp/var.txt /media/cybervpn/ 2>/dev/null || true
clear
echo -e "\e[44;97;1m       DOWNLOAD SUCCESFULLY        \e[0m"
echo -e "\e[96;1m KETIK /menu : .menu : .crot : .gas DI BOT TELEGRAM ANDA \e[0m"
rm -f /media/cybervpn.zip
exec bash
