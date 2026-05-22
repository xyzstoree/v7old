#!/bin/bash
# update.sh — Update menu pack ke versi terbaru
# FIX #12: tidak panggil `netfilter-persistent` tanpa argumen (yg cuma print usage).

red() { echo -e "\\033[32;1m${*}\\033[0m"; }
clear

if ! command -v 7z >/dev/null 2>&1; then
    apt update -y && apt install -y p7zip-full unzip
fi

fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm "$HOME/fim"
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch "$HOME/fim"
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm "$HOME/fim" && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
    tput cnorm
}

res1() {
    rm -f /tmp/menu.zip
    # FIX #11: pakai -O agar nama file deterministik
    wget -q -O /tmp/menu.zip "https://raw.githubusercontent.com/xyzstoree/v7old/main/limit/menu.zip"
    cd /tmp || return 1
    7z x menu.zip -p'coding_sendiri_lah_goblok_cuman_bisa_nyuri' -y >/dev/null 2>&1 \
        || unzip -q -P 'coding_sendiri_lah_goblok_cuman_bisa_nyuri' menu.zip
    chmod +x menu/*
    mv -f menu/* /usr/local/sbin/
    dos2unix /usr/local/sbin/install-plugin 2>/dev/null
    rm -rf /tmp/menu /tmp/menu.zip /tmp/update.sh
    cd
}

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;96m              UPDATE SCRIPT              \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo
echo -e "  \033[1;91m update script service\033[1;37m"
fun_bar 'res1'
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo
read -n 1 -s -r -p "Press [ Enter ] to back on menu"
menu
