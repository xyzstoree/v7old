#!/bin/bash
# gotop.sh — helper opsional (gotop tidak lagi wajib di install.sh)
# Pakai script ini hanya kalau kamu eksplisit mau pasang gotop.
set -e
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
if [[ -z "$gotop_latest" ]]; then
    echo "[ERROR] Gagal ambil versi gotop dari GitHub API."
    exit 1
fi
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v${gotop_latest}/gotop_v${gotop_latest}_linux_amd64.deb"
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb >/dev/null 2>&1 || apt -f install -y
rm -f /tmp/gotop.deb
echo "gotop terpasang ($gotop_latest)."
