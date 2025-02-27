#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi
if [ -z "$custom_install_dir" ]; then
    custom_install_dir="$HOME/tools/obsidian"
fi
desktop_file="$HOME/.local/share/applications/obsidian.desktop"
appImage="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.7/Obsidian-1.8.7-arm64.AppImage"

#Aarch64 has only an appimage
if [ "$(uname -m)" = "aarch64" ]; then
    curl -o "$custom_install_dir/obsidian.AppImage" -L $appImage > /dev/null 2>&1 
    chmod +x "$custom_install_dir/obsidian.AppImage"
    desktop_file_content="[Desktop Entry]
    Encoding=UTF-8
    Version=1.8.7
    Name=Obsidian MD
    GenericName=Obsidian
    Type=Application
    Exec=$custom_install_dir/obsidian.AppImage
    Icon=$custom_install_dir/obsidian.AppImage
    Categories=Notes;
    "
    echo "$desktop_file_content" > "$desktop_file"
else
    install_deb_package https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.7/obsidian_1.8.7_amd64.deb
fi
