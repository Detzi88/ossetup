#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
WINE_URL="https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources"
echo "installing wine" >>log.txt
sudo wget -NP /etc/apt/sources.list.d/ ${WINE_URL}
sudo dpkg --add-architecture i386 
sudo mkdir -pm 755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
log_and_install winehq-devel
