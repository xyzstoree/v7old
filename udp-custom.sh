#!/bin/bash
# udp-custom.sh — installer UDP custom (ePro Dev. Team)
# FIX #10: Google Drive lama (sed/confirm token) sudah patah; gunakan release URL eksplisit
#         atau LFS asset GitHub. Kalau download gagal, service tidak dibuat (no crash loop).

set -u
cd
rm -rf /etc/udp
mkdir -p /etc/udp

echo "change to time GMT+7"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# === Sumber download yang stabil ===
# Mirror dipindahkan ke GitHub release (sila ganti ke mirror milikmu sendiri).
UDP_BIN_URL="https://github.com/xyzstoree/udp-custom/releases/latest/download/udp-custom"
UDP_CFG_URL="https://github.com/xyzstoree/udp-custom/releases/latest/download/config.json"

dl_or_skip() {
    local url="$1" dst="$2"
    if wget -q --tries=2 --timeout=20 -O "$dst" "$url" && [ -s "$dst" ]; then
        return 0
    else
        echo "[ERROR] Gagal download $url — service udp-custom TIDAK akan dibuat agar tidak crash-loop."
        rm -f "$dst"
        return 1
    fi
}

echo "downloading udp-custom binary..."
if ! dl_or_skip "$UDP_BIN_URL" /etc/udp/udp-custom; then
    exit 1
fi
chmod +x /etc/udp/udp-custom

echo "downloading default config..."
dl_or_skip "$UDP_CFG_URL" /etc/udp/config.json || echo '{}' > /etc/udp/config.json
chmod 644 /etc/udp/config.json

if [ -z "${1:-}" ]; then
    SVC_EXEC="/etc/udp/udp-custom server"
else
    SVC_EXEC="/etc/udp/udp-custom server -exclude $1"
fi

cat > /etc/systemd/system/udp-custom.service <<EOF
[Unit]
Description=UDP Custom by ePro Dev. Team
After=network.target

[Service]
User=root
Type=simple
ExecStart=$SVC_EXEC
WorkingDirectory=/etc/udp/
Restart=on-failure
RestartSec=10s
StartLimitIntervalSec=60
StartLimitBurst=5

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable --now udp-custom &>/dev/null
systemctl restart udp-custom &>/dev/null
echo "udp-custom service ready."
