#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. ${SCRIPT_DIR}/../functions.sh
work_dir="$1"
custom_install_dir="$2"
WINE_URL="https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources"
sudo wget -NP /etc/apt/sources.list.d/ ${WINE_URL}
sudo dpkg --add-architecture i386 
sudo add-apt-repository "deb http://deb.debian.org/debian $(lsb_release -sc) contrib" -y
sudo mkdir -pm 755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
log_and_install winehq-devel
log_and_install winetricks
