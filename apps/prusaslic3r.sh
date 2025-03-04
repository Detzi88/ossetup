#!/bin/bash
prusaslic3r_deps=("flatpak" "gnome-software-plugin-flatpak")

install_prusaslic3r(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    work_dir="$1"
    custom_install_dir="$2"
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install flathub com.prusa3d.PrusaSlicer -y
}

