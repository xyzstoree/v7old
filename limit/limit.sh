#!/bin/bash
# limit.sh — installer service quota XRay
# FIX #11: pakai -O dengan path absolut, file service tidak chmod +x
REPO="https://raw.githubusercontent.com/xyzstoree/v7old/main/"

# Library bersama untuk vmess/vless/trojan
wget -q -O /etc/xray/_limit_proto.lib "${REPO}limit/_limit_proto.lib"

for proto in vmess vless trojan shadowsocks; do
    wget -q -O "/etc/systemd/system/limit${proto}.service" "${REPO}limit/limit${proto}.service"
    chmod 644 "/etc/systemd/system/limit${proto}.service"
    wget -q -O "/etc/xray/limit.${proto}" "${REPO}limit/${proto}"
    chmod +x "/etc/xray/limit.${proto}"
done

systemctl daemon-reload
for proto in vmess vless trojan shadowsocks; do
    systemctl enable --now "limit${proto}"
done
