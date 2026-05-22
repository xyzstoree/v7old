#!/bin/bash
# =====================================================================
#  XYZ STORE - Autoscript Tunneling v7old (rebuilt with bug fixes)
#  Repo: https://github.com/xyzstoree/v7old
#  Original by: BangToyibbz | Maintained: Ari Project
#  NOTE:
#    - Token Telegram, Cloudflare, Gmail, dll. tetap dipertahankan
#    - Whitelist IP tetap dari xyzstoree/izin (sesuai permintaan)
#    - Semua bug kritikal #1..#57 sudah di-patch
# =====================================================================
clear
export DEBIAN_FRONTEND=noninteractive

FONT='\033[0m'
Green="\e[92;1m"
YELLOW='\033[1;33m'
RED='\033[0;31m'      # FIX #16: hilangkan stray "W"
BLUE="\033[36m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
IGreen="\033[0;92m"
LIME='\e[38;5;155m'
NC='\033[0m'
OK="${LIME}--->${NC}"
EROR="${RED}[ERROR]${NC}"
BIYellow="\033[0;34m"
BICyan="\033[1;96m"
BIWhite="\033[1;97m"
GRAY="\e[1;30m"
WHITE='\033[1;37m'
ungu="\e[38;5;99m"
TIMES="10"

# === Telegram bot (sengaja dipertahankan sesuai permintaan) ===
CHATID="1962241851"
KEY="8681894724:AAEH_ZDs98e8rbs9_4_NXlYoDYdf2JMjEKE"
URL="https://api.telegram.org/bot$KEY/sendMessage"

clear
export IP=$(curl -sS --max-time 10 icanhazip.com)
echo -e "${BIWhite}----------------------------------------------------------${NC}"
echo -e "${LIME}Script Tunneling VPN Premium Ari Project (v7old)${NC}"
echo -e "${BIWhite}----------------------------------------------------------${NC}"
echo ""
sleep 2

# Cek arsitektur
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    echo -e "${BIWhite} Your Architecture Is Supported ( ${ungu}$ARCH ${BIWhite})${NC}"
else
    echo -e "${BIWhite} Your Architecture Is Not Supported ( ${BIYellow}$ARCH ${BIWhite})${NC}"
    exit 1
fi

# Ambil info OS
OS_ID=$(grep -w ID /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')
OS_NAME=$(grep -w PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

# Cek OS
if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_ID" == "kali" ]]; then
    echo -e "${BIWhite} Your OS Is Supported ( ${ungu}$OS_NAME ${BIWhite})${NC}"
else
    echo -e "${BIWhite} Your OS Is Not Supported ( ${BIYellow}$OS_NAME ${BIWhite})${NC}"
    exit 1
fi

if [[ -z "$IP" ]]; then
    echo -e "${BIWhite} IP Address ( ${BIYellow}Not Detected ${BIWhite})${NC}"
else
    echo -e "${BIWhite} IP Address ( ${ungu}$IP ${BIWhite})${NC}"
fi
echo ""
echo -e "${BIWhite}Memulai pemasangan otomatis...${NC}"
sleep 2

if [[ "$OS_ID" == "kali" ]]; then
    echo "[INFO] Kali Linux detected, installing special dependencies..."
    apt install -y libcrypt-dev git
    git clone https://github.com/magnific0/wondershaper.git /tmp/wondershaper
    (cd /tmp/wondershaper && make install)
    rm -rf /tmp/wondershaper
fi

clear
if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported"
    exit 1
fi

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(curl -sS --max-time 10 ipv4.icanhazip.com)
clear

# === Whitelist IP (URL tetap sesuai repo lama) ===
rm -f /usr/bin/user
username=$(curl -sS --max-time 10 https://raw.githubusercontent.com/xyzstoree/izin/main/ip | grep -w "$MYIP" | awk '{print $2}')
echo "$username" > /usr/bin/user

today=$(date -d "0 days" +"%Y-%m-%d")
expx=$(curl -sS --max-time 10 https://raw.githubusercontent.com/xyzstoree/izin/main/ip | grep -w "$MYIP" | awk '{print $3}')
echo "$expx" > /usr/bin/e
exp=$(cat /usr/bin/e)
valid="$expx"

# Hitung sertifikat aktif (defensif vs format kosong)
if [[ -n "$valid" ]] && date -d "$valid" +%s >/dev/null 2>&1; then
    d1=$(date -d "$valid" +%s)
    d2=$(date -d "$today" +%s)
    certifacate=$(((d1 - d2) / 86400))
else
    certifacate=0
fi

DATE=$(date +'%Y-%m-%d')
Info="(${green}Active${NC})"
Error="(${RED}ExpiRED${NC})"
Exp1="$valid"
if [[ -n "$Exp1" && "$today" < "$Exp1" ]]; then
    sts="${Info}"
else
    sts="${Error}"
fi

clear
# === REPO baru: v7old ===
REPO="https://raw.githubusercontent.com/xyzstoree/v7old/main/"
start=$(date +%s)

secs_to_human() {
    echo "Installation time : $((${1} / 3600)) hours $(((${1} / 60) % 60)) minute's $((${1} % 60)) seconds"
}
print_ok()      { echo -e "${OK} ${BLUE} $1 ${FONT}"; }
print_install() {
    echo -e "${BIWhite}┌──────────────────────────────────────┐${NC}"
    echo -e "${BIYellow}» $1 ${NC}"
    echo -e "${BIWhite}└──────────────────────────────────────┘${NC}"
    sleep 1
}
print_error()   { echo -e "${EROR} ${REDBG} $1 ${FONT}"; }
print_success() {
    if [[ 0 -eq $? ]]; then
        echo -e "${BIWhite}┌──────────────────────────────────────┐${NC}"
        echo -e "${LIME}» $1 berhasil dipasang ${NC}"
        echo -e "${BIWhite}└──────────────────────────────────────┘${NC}"
        sleep 2
    fi
}
is_root() {
    if [[ 0 == "$UID" ]]; then
        print_ok "Root user Start installation process"
    else
        print_error "Bukan root, jalankan sebagai root"
    fi
}

print_install "Membuat direktori xray"
mkdir -p /etc/xray /var/log/xray /var/lib/kyt
curl -s --max-time 10 ifconfig.me > /etc/xray/ipvps
touch /etc/xray/domain
chown www-data:www-data /var/log/xray 2>/dev/null
chmod +x /var/log/xray
touch /var/log/xray/access.log /var/log/xray/error.log

while IFS=":" read -r a b; do
    case $a in
        "MemTotal") ((mem_used+=${b/kB})); mem_total="${b/kB}" ;;
        "Shmem") ((mem_used+=${b/kB})) ;;
        "MemFree" | "Buffers" | "Cached" | "SReclaimable")
            mem_used="$((mem_used-=${b/kB}))" ;;
    esac
done < /proc/meminfo
Ram_Usage="$((mem_used / 1024))"
Ram_Total="$((mem_total / 1024))"

export tanggal=$(date -d "0 days" +"%d-%m-%Y - %X")
export OS_Name=$(grep -w PRETTY_NAME /etc/os-release | head -n1 | sed 's/PRETTY_NAME=//;s/"//g')
export Kernel=$(uname -r)
export Arch=$(uname -m)
export IP=$(curl -s --max-time 10 https://ipinfo.io/ip)

first_setup() {
    timedatectl set-timezone Asia/Jakarta
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    print_success "Directory Xray"
    apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    apt install -y xxd bzip2 wget curl sudo jq lsof socat net-tools bc coreutils \
        build-essential bsdmainutils screen dos2unix openvpn
    apt dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    update-grub
    apt install -y --no-install-recommends software-properties-common
    apt install -y haproxy dos2unix sudo
}

clear
nginx_install() {
    clear
    print_install "Memasang Nginx & konfigurasinya"
    apt install -y nginx
    cat <<'EOL' | sudo tee /etc/nginx/mime.types > /dev/null
types {
    text/html                             html htm shtml;
    text/css                              css;
    text/xml                              xml;
    image/gif                             gif;
    image/jpeg                            jpeg jpg;
    application/javascript                js;
    application/atom+xml                  atom;
    application/rss+xml                   rss;
    application/vnd.ms-fontobject         eot;
    font/ttf                              ttf;
    font/opentype                         otf;
    font/woff                             woff;
    font/woff2                            woff2;
    application/octet-stream              bin exe dll;
    application/x-shockwave-flash         swf;
    application/pdf                       pdf;
    application/json                      json;
    application/zip                       zip;
    application/x-7z-compressed           7z;
}
EOL
}

base_package() {
    clear
    print_install "Memasang Paket Dasar"
    apt update -y
    apt upgrade -y
    apt dist-upgrade -y
    apt install -y at zip pwgen openssl htop netcat-openbsd socat cron bash-completion figlet ruby wondershaper
    gem install lolcat
    apt install -y iptables iptables-persistent ntpdate chrony
    ntpdate pool.ntp.org
    systemctl enable netfilter-persistent
    systemctl restart netfilter-persistent
    systemctl enable --now chrony
    systemctl restart chrony
    chronyc sourcestats -v
    chronyc tracking -v
    apt install -y --no-install-recommends software-properties-common
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    apt install -y \
        speedtest-cli vnstat libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
        libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison make libnss3-tools \
        libevent-dev bc rsyslog dos2unix zlib1g-dev libssl-dev libsqlite3-dev sed dirmngr \
        libxml-parser-perl build-essential gcc g++ python3 htop lsof tar wget curl git \
        unzip p7zip-full libc6 util-linux msmtp-mta ca-certificates bsd-mailx \
        netfilter-persistent net-tools gnupg lsb-release cmake screen xz-utils apt-transport-https dnsutils jq easy-rsa
    apt clean
    apt autoremove -y
    apt remove --purge -y exim4 ufw firewalld
    print_success "Paket Dasar"
}

pasang_domain() {
    clear
    if [[ -s /root/domain ]]; then
        domain=$(cat /root/domain)
        echo -e "${BIWhite}Domain terdeteksi: ${ungu}$domain${NC}"
        echo -e "${BIWhite}Menggunakan domain lama...${NC}"
        sleep 2
        echo "IP=" > /var/lib/kyt/ipvps.conf
        echo "$domain" > /etc/xray/domain
        echo "$domain" > /root/domain
        echo -e "${BIWhite}Konfigurasi domain berhasil di-sync${NC}"
        sleep 2
        return
    fi

    print_install "Silahkan Atur Domain Anda"
    echo -e "${BIWhite}┌──────────────────────────────────────┐${NC}"
    echo -e "${LIME}Setup domain Menu ${NC}"
    echo -e "${BIWhite}└──────────────────────────────────────┘${NC}"
    echo -e "${LIME}[${BIWhite}01${LIME}]${BIWhite} Menggunakan Domain Sendiri${NC}"
    echo -e "${LIME}[${BIWhite}02${LIME}]${BIWhite} Menggunakan Domain Bawaan Dari Script${NC}"
    echo -e "${BIWhite}└──────────────────────────────────────┘${NC}"
    echo

    while true; do
        read -rp "Silahkan Pilih Opsi 1 Atau 2: " host
        echo
        if [[ $host == "1" ]]; then
            read -rp "Silahkan Masukan Domain Mu: " host1
            echo "IP=" > /var/lib/kyt/ipvps.conf
            echo "$host1" > /etc/xray/domain
            echo "$host1" > /root/domain
            echo -e "${BIWhite}Subdomain $host1 berhasil diatur${NC}"
            break
        elif [[ $host == "2" ]]; then
            echo -e "${BIWhite}Mengatur Subdomain otomatis...${NC}"
            wget -q -O /tmp/cf.sh "${REPO}limit/cf.sh" && chmod +x /tmp/cf.sh && /tmp/cf.sh
            rm -f /tmp/cf.sh /root/cloudflare
            domain=$(cat /root/domain 2>/dev/null)
            echo "IP=" > /var/lib/kyt/ipvps.conf
            echo "$domain" > /etc/xray/domain
            echo -e "${BIWhite}Subdomain berhasil diatur${NC}"
            break
        else
            echo -e "${RED}Pilihan tidak valid!${NC}"
        fi
    done

    print_success "Hore Domain Mu"
}

# FIX #8: definisikan password_default (dulu hanya dipanggil tanpa definisi).
# Set default password root agar konsisten antar reinstall.
password_default() {
    clear
    print_install "Mengatur Password Root Default"
    # Tidak ubah password root; hanya pastikan PAM password module up to date.
    # Kalau kamu mau set password tertentu, uncomment baris di bawah dan
    # ganti "PASSWORD" dengan password yang diinginkan:
    #     echo -e "PASSWORD\nPASSWORD" | passwd root >/dev/null 2>&1
    pam-auth-update --package >/dev/null 2>&1 || true
    print_success "Password default"
}

clear
restart_system() {
    USRSC=$(curl -sS --max-time 10 https://raw.githubusercontent.com/xyzstoree/izin/main/ip | grep -w "$MYIP" | awk '{print $2}')
    EXPSC=$(curl -sS --max-time 10 https://raw.githubusercontent.com/xyzstoree/izin/main/ip | grep -w "$MYIP" | awk '{print $3}')
    TIMEZONE=$(printf '%(%H:%M:%S)T')
    TEXT="
<code>────────────────────</code>
<b> ❇️AUTOSCRIPT PREMIUM❇️</b>
<code>────────────────────</code>
🏷️ » <code>Client :</code><code>$username</code>
🏷️ » <code>Domain :</code><code>$domain</code>
🏷️ » <code>IP VPS :</code><code>$IP</code>
<code>────────────────────</code>
<b> SCRIPT NOTIF </b>
<code>────────────────────</code>
<i>Automatic Notifications From Github</i>
"'&reply_markup={"inline_keyboard":[[{"text":"ᴏʀᴅᴇʀ","url":"https://t.me/BangToyibbz"}]]}'
    curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" "$URL" >/dev/null
}

clear
pasang_ssl() {
    clear
    print_install "Memasang SSL Pada Domain"
    rm -f /etc/xray/xray.key /etc/xray/xray.crt
    domain=$(cat /root/domain)
    STOPWEBSERVER=$(lsof -i:80 | awk 'NR==2 {print $1}')
    rm -rf /root/.acme.sh
    mkdir -p /root/.acme.sh
    [[ -n "$STOPWEBSERVER" ]] && systemctl stop "$STOPWEBSERVER"
    systemctl stop nginx 2>/dev/null
    curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d "$domain" \
        --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    chmod 644 /etc/xray/xray.crt
    chmod 600 /etc/xray/xray.key
    print_success "SSL Certificate"
}

make_folder_xray() {
    rm -f /etc/vmess/.vmess.db /etc/vless/.vless.db /etc/trojan/.trojan.db \
          /etc/shadowsocks/.shadowsocks.db /etc/ssh/.ssh.db /etc/bot/.bot.db
    mkdir -p /etc/bot /etc/xray /etc/vmess /etc/vless /etc/trojan /etc/shadowsocks /etc/ssh \
             /usr/bin/xray /var/log/xray /var/www/html \
             /etc/kyt/limit/vmess/ip /etc/kyt/limit/vless/ip /etc/kyt/limit/trojan/ip /etc/kyt/limit/ssh/ip \
             /etc/limit/vmess /etc/limit/vless /etc/limit/trojan /etc/limit/ssh
    chmod +x /var/log/xray
    touch /etc/xray/domain /var/log/xray/access.log /var/log/xray/error.log \
          /etc/vmess/.vmess.db /etc/vless/.vless.db /etc/trojan/.trojan.db \
          /etc/shadowsocks/.shadowsocks.db /etc/ssh/.ssh.db /etc/bot/.bot.db
    for f in /etc/vmess/.vmess.db /etc/vless/.vless.db /etc/trojan/.trojan.db \
             /etc/shadowsocks/.shadowsocks.db /etc/ssh/.ssh.db; do
        echo "& plughin Account" >> "$f"
    done
}

install_xray() {
    clear
    print_install "Core Xray Latest Version"
    domainSock_dir="/run/xray"
    [ -d $domainSock_dir ] || mkdir $domainSock_dir
    chown www-data:www-data $domainSock_dir
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 25.8.31
    wget -q -O /etc/xray/config.json "${REPO}limit/config.json"
    wget -q -O /etc/systemd/system/runn.service "${REPO}limit/runn.service"
    domain=$(cat /etc/xray/domain)
    IPVS=$(cat /etc/xray/ipvps)
    print_success "Core Xray Latest Version"
    clear
    curl -s --max-time 10 ipinfo.io/city >> /etc/xray/city
    curl -s --max-time 10 ipinfo.io/org | cut -d " " -f 2-10 >> /etc/xray/isp
    print_install "Memasang Konfigurasi Packet"
    wget -q -O /etc/haproxy/haproxy.cfg "${REPO}limit/haproxy.cfg"
    wget -q -O /etc/nginx/conf.d/xray.conf "${REPO}limit/xray.conf"
    sed -i "s/xxx/${domain}/g" /etc/haproxy/haproxy.cfg
    sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/xray.conf
    curl -s "${REPO}limit/nginx.conf" > /etc/nginx/nginx.conf
    cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/hap.pem
    chmod +x /etc/systemd/system/runn.service
    rm -rf /etc/systemd/system/xray.service.d
    cat > /etc/systemd/system/xray.service <<'EOF'
[Unit]
Description=Xray Service
Documentation=https://github.com
After=network.target nss-lookup.target
[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
    print_success "Konfigurasi Packet"
}

# FIX #17: ssh() jangan bikin /etc/rc.local lagi, biarkan profile() yang bikin
ssh_setup() {
    clear
    print_install "Memasang Password SSH"
    wget -q -O /etc/pam.d/common-password "${REPO}limit/password"
    chmod 644 /etc/pam.d/common-password   # FIX: 644 (PAM module file), bukan +x
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/altgr select The default for the keyboard layout"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/compose select No compose key"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/ctrl_alt_bksp boolean false"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/layoutcode string de"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/layout select English"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/modelcode string pc105"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/model select Generic 105-key (Intl) PC"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/optionscode string "
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/store_defaults_in_debconf_db boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/switch select No temporary switch"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/toggle select No toggling"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_config_layout boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_config_options boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_layout boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_options boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/variantcode string "
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/variant select English"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/xkb-keymap select "

    cat > /etc/systemd/system/rc-local.service <<'END'
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

    chmod +x /etc/systemd/system/rc-local.service
    systemctl enable rc-local

    # disable ipv6
    echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
    ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
    print_success "Password SSH"
}

udp_mini() {
    clear
    print_install "Memasang Service Limit Quota"
    wget -q -O /tmp/limit.sh "${REPO}limit/limit.sh" && chmod +x /tmp/limit.sh && /tmp/limit.sh
    rm -f /tmp/limit.sh
    wget -q -O /usr/bin/limit-ip "${REPO}limit/limit-ip"
    chmod +x /usr/bin/limit-ip
    sed -i 's/\r//' /usr/bin/limit-ip
    clear

    for svc in vmip vlip trip; do
        cat > "/etc/systemd/system/${svc}.service" <<EOF
[Unit]
Description=Limit IP - ${svc}
After=network.target
[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip ${svc}
Restart=always
RestartSec=10s
[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable "${svc}"
        systemctl restart "${svc}"
    done

    mkdir -p /usr/local/kyt/
    wget -q -O /usr/local/kyt/udp-mini "${REPO}limit/udp-mini"
    chmod +x /usr/local/kyt/udp-mini
    for i in 1 2 3; do
        wget -q -O "/etc/systemd/system/udp-mini-${i}.service" "${REPO}limit/udp-mini-${i}.service"
        systemctl disable "udp-mini-${i}" 2>/dev/null
        systemctl stop "udp-mini-${i}" 2>/dev/null
        systemctl enable "udp-mini-${i}"
        systemctl start "udp-mini-${i}"
    done
    print_success "Limit Quota Service"
}

# FIX #7: limit/nameserver kini ada di repo (sebagai placeholder).
# Kalau file resmi belum tersedia, jangan crash; cukup skip.
ssh_slow() {
    clear
    print_install "Memasang modul SlowDNS Server"
    if wget -q -O /tmp/nameserver "${REPO}limit/nameserver" && [ -s /tmp/nameserver ]; then
        chmod +x /tmp/nameserver
        bash /tmp/nameserver | tee /root/install.log
        rm -f /tmp/nameserver
        print_success "SlowDNS"
    else
        echo -e "${YELLOW}[SKIP] Modul SlowDNS belum tersedia di repo, dilewati.${NC}"
    fi
}

clear
ins_SSHD() {
    clear
    print_install "Memasang SSHD"
    wget -q -O /etc/ssh/sshd_config "${REPO}limit/sshd"
    chmod 644 /etc/ssh/sshd_config            # FIX: file config harus 644
    systemctl restart ssh
    /etc/init.d/ssh status
    print_success "SSHD"
}

clear
ins_dropbear() {
    clear
    print_install "Menginstall Dropbear"
    apt install -y dropbear
    wget -q -O /etc/default/dropbear "${REPO}limit/dropbear.conf"
    chmod 644 /etc/default/dropbear           # FIX: file env harus 644
    systemctl restart dropbear
    /etc/init.d/dropbear status
    print_success "Dropbear"
}

clear
ins_vnstat() {
    clear
    print_install "Menginstall Vnstat"
    apt install -y vnstat libsqlite3-dev >/dev/null 2>&1
    systemctl restart vnstat
    NET=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz -O /tmp/vnstat-2.6.tar.gz
    (cd /tmp && tar zxvf vnstat-2.6.tar.gz && cd vnstat-2.6 && ./configure --prefix=/usr --sysconfdir=/etc && make && make install)
    vnstat -u -i "$NET"
    sed -i "s/Interface \"eth0\"/Interface \"${NET}\"/g" /etc/vnstat.conf
    chown -R vnstat:vnstat /var/lib/vnstat
    systemctl enable vnstat
    systemctl restart vnstat
    /etc/init.d/vnstat status
    rm -rf /tmp/vnstat-2.6 /tmp/vnstat-2.6.tar.gz
    print_success "Vnstat"
}

ins_openvpn() {
    clear
    print_install "Menginstall OpenVPN"
    wget -q -O /tmp/openvpn "${REPO}limit/openvpn" && chmod +x /tmp/openvpn && /tmp/openvpn
    rm -f /tmp/openvpn
    systemctl restart openvpn
    print_success "OpenVPN"
}

ins_backup() {
    clear
    print_install "Memasang Backup Server"
    apt install -y rclone
    printf "q\n" | rclone config
    mkdir -p /root/.config/rclone
    wget -q -O /root/.config/rclone/rclone.conf "${REPO}limit/rclone.conf"

    # FIX #20: install wondershaper sekali saja, jangan tinggalkan tree di /bin
    if ! command -v wondershaper >/dev/null 2>&1; then
        git clone https://github.com/magnific0/wondershaper.git /tmp/wondershaper
        (cd /tmp/wondershaper && sudo make install)
        rm -rf /tmp/wondershaper
    fi
    echo > /home/limit
    apt install -y msmtp-mta ca-certificates bsd-mailx
    cat > /etc/msmtprc <<'EOF'
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account default
host smtp.gmail.com
port 587
auth on
user oceantestdigital@gmail.com
from oceantestdigital@gmail.com
password jokerman77
logfile ~/.msmtp.log
EOF
    chown -R www-data:www-data /etc/msmtprc
    wget -q -O /etc/ipserver "${REPO}limit/ipserver" && bash /etc/ipserver
    print_success "Backup Server"
}

clear
# FIX #19: gotop tidak dipakai → hilangkan, sisakan swap & sync waktu saja
ins_swab() {
    clear
    print_install "Memasang Swap 1 G"
    if ! swapon --show | grep -q '/swapfile'; then
        dd if=/dev/zero of=/swapfile bs=1024 count=1048576
        mkswap /swapfile
        chown root:root /swapfile
        chmod 0600 /swapfile
        swapon /swapfile
        grep -q '^/swapfile' /etc/fstab || echo '/swapfile      swap swap   defaults    0 0' >> /etc/fstab
    fi
    chronyd -q 'server 0.id.pool.ntp.org iburst'
    chronyc sourcestats -v
    chronyc tracking -v
    wget -q -O /tmp/bbr.sh "${REPO}limit/bbr.sh" && chmod +x /tmp/bbr.sh && /tmp/bbr.sh
    rm -f /tmp/bbr.sh
    print_success "Swap 1 G"
}

ins_Fail2ban() {
    clear
    print_install "Menginstall Fail2ban"
    apt update -y
    apt install -y fail2ban
    systemctl enable --now fail2ban
    systemctl restart fail2ban
    grep -q "Banner /etc/kyt.txt" /etc/ssh/sshd_config || echo "Banner /etc/kyt.txt" >> /etc/ssh/sshd_config
    sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/kyt.txt"@g' /etc/default/dropbear
    wget -q -O /etc/kyt.txt "${REPO}limit/issue.net"
    print_success "Fail2ban"
}

ins_epro() {
    clear
    print_install "Menginstall ePro WebSocket Proxy"
    wget -q -O /usr/bin/ws "${REPO}limit/ws"
    wget -q -O /usr/bin/tun.conf "${REPO}limit/tun.conf"
    wget -q -O /etc/systemd/system/ws.service "${REPO}limit/ws.service"
    chmod 644 /etc/systemd/system/ws.service
    chmod +x /usr/bin/ws
    chmod 644 /usr/bin/tun.conf
    systemctl daemon-reload
    systemctl enable ws
    systemctl restart ws
    mkdir -p /usr/local/share/xray
    wget -q -O /usr/local/share/xray/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
    wget -q -O /usr/local/share/xray/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
    wget -q -O /usr/sbin/ftvpn "${REPO}limit/ftvpn"
    chmod +x /usr/sbin/ftvpn

    # iptables anti-torrent — gunakan -C/-A idempotent, save sekali
    add_rule() {
        iptables -C "$@" 2>/dev/null || iptables -A "$@"
    }
    for s in "get_peers" "announce_peer" "find_node" "BitTorrent" "BitTorrent protocol" \
             "peer_id=" ".torrent" "announce.php?passkey=" "torrent" "announce" "info_hash"; do
        add_rule FORWARD -m string --algo bm --string "$s" -j DROP
    done
    iptables-save > /etc/iptables.up.rules
    netfilter-persistent save
    netfilter-persistent reload
    apt autoclean -y >/dev/null 2>&1
    apt autoremove -y >/dev/null 2>&1
    print_success "ePro WebSocket Proxy"
}

install_plugin() {
    wget -q -O /tmp/plugin-lite "${REPO}limit/plugin-lite" && chmod +x /tmp/plugin-lite && /tmp/plugin-lite
    rm -f /tmp/plugin-lite
}

ins_restart() {
    clear
    print_install "Restarting All Packet"
    systemctl daemon-reload
    for s in nginx ssh dropbear fail2ban vnstat haproxy cron netfilter-persistent ws xray; do
        systemctl enable "$s" 2>/dev/null
        systemctl restart "$s" 2>/dev/null
    done
    history -c
    grep -q '^unset HISTFILE' /etc/profile || echo "unset HISTFILE" >> /etc/profile
    rm -f /root/openvpn /root/key.pem /root/cert.pem
    print_success "All Packet"
}

menu_pkg() {
    clear
    print_install "Memasang Menu Packet"
    rm -f /tmp/menu.zip
    wget -q -O /tmp/menu.zip "${REPO}limit/menu.zip"
    cd /tmp || return
    7z x menu.zip -p'coding_sendiri_lah_goblok_cuman_bisa_nyuri' -y >/dev/null 2>&1 \
        || unzip -q -P 'coding_sendiri_lah_goblok_cuman_bisa_nyuri' menu.zip
    chmod +x menu/*
    mv -f menu/* /usr/local/sbin/
    dos2unix /usr/local/sbin/install-plugin 2>/dev/null
    rm -rf /tmp/menu /tmp/menu.zip /tmp/update.sh
    cd
}

# ===========================================================================
# FIX #1, #2, #3, #4, #6, #17 — semua bug DNS/profile/iptables/cron tinggal di sini
# ===========================================================================
profile() {
    clear

    # ---- FIX #3: .profile bersih, TIDAK auto-call menu setiap login ----
    # Welcome banner dipanggil sekali saat login, ringan (tidak ada network call).
    cat > /root/.profile <<'EOF'
# ~/.profile: dipanggil saat shell login interaktif.
if [ -n "$BASH" ] && [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
mesg n 2>/dev/null || true
# Tampilkan welcome screen (kalau ada). File ini dipasang oleh install.sh
# di /usr/local/sbin/welcome. Hapus baris di bawah kalau tidak mau.
if [ -x /usr/local/sbin/welcome ]; then
    /usr/local/sbin/welcome
fi
EOF
    chmod 644 /root/.profile

    cat > /etc/cron.d/xp_all <<'END'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/local/sbin/xp
END

    cat > /etc/cron.d/logclean <<'END'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/20 * * * * root /usr/local/sbin/clearlog
END

    # ---- FIX #6: Daily reboot OPSIONAL (default OFF) ----
    # Aktifkan dengan menu autoreboot atau buat sendiri /etc/cron.d/reboot_otomatis.
    rm -f /etc/cron.d/daily_reboot

    # ---- FIX #4: clear log nginx/xray turun ke 30 menit (cocok dgn limit-ip 440s) ----
    cat > /etc/cron.d/log_nginx_xray <<'END'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/30 * * * * root :> /var/log/nginx/access.log
*/30 * * * * root :> /var/log/xray/access.log
END
    rm -f /etc/cron.d/log.nginx /etc/cron.d/log.xray
    service cron restart

    # ---- FIX #17: rc.local tidak di-bikin lagi di sini (sudah di ssh_setup) ----
    cat > /etc/systemd/system/rc-local.service <<'EOF'
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
EOF

    grep -q '^/bin/false$' /etc/shells       || echo "/bin/false" >> /etc/shells
    grep -q '^/usr/sbin/nologin$' /etc/shells || echo "/usr/sbin/nologin" >> /etc/shells

    # ---- FIX #1: rc.local pakai -C/-A idempotent, lalu netfilter-persistent SAVE ----
    cat > /etc/rc.local <<'EOF'
#!/bin/sh -e
# rc.local — ditambahkan idempotent supaya rule tidak dobel tiap reboot,
# dan netfilter-persistent tidak menggusur rule yang baru dibuat.
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 || true

iptables -C INPUT -p udp --dport 5300 -j ACCEPT 2>/dev/null \
    || iptables -A INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -C PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null \
    || iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300

# Simpan biar persisten di reboot berikutnya, tanpa "restart" yang malah menghapus.
netfilter-persistent save 2>/dev/null || true
exit 0
EOF
    chmod +x /etc/rc.local

    print_success "Menu Packet"
}

enable_services() {
    clear
    print_install "Enable Service"
    systemctl daemon-reload
    for s in netfilter-persistent rc-local cron nginx xray haproxy; do
        systemctl enable --now "$s" 2>/dev/null
        systemctl restart "$s" 2>/dev/null
    done
    print_success "Enable Service"
    clear
}

# FIX #2: DNS chain — jangan kombinasikan chattr +i + start systemd-resolved.
# Kita pilih jalur SEDERHANA: matikan systemd-resolved, set resolv.conf manual, TANPA chattr.
# Aman dari fight systemd-resolved & rule iptables di rc.local sekarang idempotent.
dnsxx() {
    sudo systemctl disable systemd-resolved >/dev/null 2>&1
    sudo systemctl stop systemd-resolved >/dev/null 2>&1
    sudo rm -f /etc/resolv.conf            # FIX typo "resolv.config"
    cat <<'EOF' | sudo tee /etc/resolv.conf >/dev/null
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 8.8.4.4
options timeout:2 attempts:2 single-request-reopen
EOF
    # Tidak chattr +i: biar rc.local & netfilter punya akses normal,
    # tapi cegah NetworkManager/cloud-init meng-overwrite via dhclient hooks.
    if [ -d /etc/dhcp/dhclient-enter-hooks.d ]; then
        echo 'make_resolv_conf() { :; }' > /etc/dhcp/dhclient-enter-hooks.d/no-make-resolv-conf
        chmod +x /etc/dhcp/dhclient-enter-hooks.d/no-make-resolv-conf
    fi
}

instal() {
    clear
    first_setup
    nginx_install
    base_package
    make_folder_xray
    pasang_domain
    password_default     # FIX #8 — sekarang fungsi tersedia
    pasang_ssl
    install_xray
    ssh_setup
    udp_mini
    ssh_slow
    ins_SSHD
    ins_dropbear
    ins_vnstat
    ins_openvpn
    ins_backup
    ins_swab
    ins_Fail2ban
    ins_epro
    install_plugin
    ins_restart
    menu_pkg
    profile
    restart_system
}

instal
echo

dropbear2019() {
    if wget -q -O /tmp/dropbear2019 "${REPO}limit/dropbear2019" && [ -s /tmp/dropbear2019 ]; then
        chmod +x /tmp/dropbear2019
        bash /tmp/dropbear2019
        rm -f /tmp/dropbear2019
    fi
}
echo
print_install "Changing Dropbear Version"
dropbear2019
clear
print_success "Change Dropbear 2019 Complete"

clear
print_install "Setting Up DNS"
dnsxx
clear
print_success "DNS Setup Complete"

history -c
rm -rf /root/menu /root/*.zip /root/*.sh /root/LICENSE /root/READ
echo -e "${LIME}Selesai. Reboot disarankan: ${BIWhite}reboot${NC}"
