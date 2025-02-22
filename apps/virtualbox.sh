#!/bin/bash
work_dir="$1"
echo "installing virtualbox" >>log.txt
curl -o "$work_dir/vbox.deb" -L "https://download.virtualbox.org/virtualbox/7.0.20/virtualbox-7.0_7.0.20-163906~Ubuntu~noble_amd64.deb"
sudo apt install "$work_dir/vbox.deb" -y
rm "$work_dir/vbox.deb"
usermod -a -G vboxusers $USER
