#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. ${SCRIPT_DIR}/../functions.sh
work_dir="$1"
custom_install_dir="$2"
#Flatpak is now the official way to do it.
log_and_install flatpak
log_and_install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.prusa3d.PrusaSlicer -y
