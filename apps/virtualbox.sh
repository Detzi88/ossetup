#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
echo "installing virtualbox" >>log.txt
curl -o "$work_dir/vbox.deb" -L "https://download.virtualbox.org/virtualbox/7.0.20/virtualbox-7.0_7.0.20-163906~Ubuntu~noble_amd64.deb"
wait_for_apt_lock
sudo apt install "$work_dir/vbox.deb" -y
rm "$work_dir/vbox.deb"
usermod -a -G vboxusers $USER
