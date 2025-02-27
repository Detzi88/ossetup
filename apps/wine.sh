#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
echo "installing wine" >>log.txt
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
sudo dpkg --add-architecture i386 
sudo mkdir -pm 755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wait_for_apt_lock
sudo apt update 
sudo apt install --install-recommends winehq-devel -y
