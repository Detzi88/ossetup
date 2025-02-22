#!/bin/bash
work_dir="$1"
custom_install_dir="$2"
install_deb_package https://vscode.download.prss.microsoft.com/dbazure/download/stable/fee1edb8d6d72a0ddff41e5f71a671c23ed924b9/code_1.92.2-1723660989_amd64.deb
sudo update-alternatives --install /usr/bin/gnome-text-editor gnome-text-editor /usr/bin/code 100
