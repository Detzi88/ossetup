#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
#Flatpak is now the official way to do it.
wait_for_apt_lock
sudo apt update
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.prusa3d.PrusaSlicer -y
