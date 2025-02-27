#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi
sudo dpkg --add-architecture i386
steam_deps=("libc6:amd64" "libc6:i386" "libegl1:amd64" "libegl1:i386" "libgbm1:amd64" "libgbm1:i386" "libgl1-mesa-dri:amd64" "libgl1-mesa-dri:i386" "libgl1:amd64" "libgl1:i386" "steam-libs-amd64:amd64")
install_deb_package https://cdn.akamai.steamstatic.com/client/installer/steam.deb

for app in "${steam_deps[@]}"; do
    log_and_install "$app" ${NOUPDATE}
    NOUPDATE="--noupdate"
done
rm $HOME/Desktop/steam.desktop
#let steam update in the "Background"
steam &
