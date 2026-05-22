#!/bin/bash
# cf.sh — buat subdomain Cloudflare otomatis
# Token & email Cloudflare DIPERTAHANKAN sesuai permintaan user.
set -euo pipefail

apt install -y jq curl

read -rp "Masukan Domain (contoh : free): " domen
DOMAIN="alhamdulliah.web.id"
sub="${domen}"
dns="${sub}.${DOMAIN}"

CF_ID="aribuncar285@gmail.com"
CF_KEY="3a9c22d2f262547b15d58da5b93e884985edb"

IP=$(curl -sS --max-time 10 icanhazip.com)
echo "Updating DNS for ${dns} -> ${IP} ..."

ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

if [[ -z "$ZONE" ]]; then
    echo "[ERROR] Zone Cloudflare tidak ditemukan untuk ${DOMAIN}."
    exit 1
fi

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${dns}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

if [[ -z "$RECORD" || "${#RECORD}" -le 10 ]]; then
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"${dns}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}" \
        | jq -r '.result.id // empty')
fi

curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"${dns}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}" >/dev/null

mkdir -p /var/lib/kyt /etc/xray /etc/v2ray
echo "$dns" | tee /root/domain /root/scdomain /etc/xray/domain /etc/v2ray/domain /etc/xray/scdomain >/dev/null
echo "IP=$dns" > /var/lib/kyt/ipvps.conf
echo "Domain ${dns} berhasil dibuat di Cloudflare."
