#!/bin/bash
work_dir="$1"
custom_install_dir="$2"
arduino_installer="https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.zip"
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi
curl -o "$work_dir/arduino.zip" -L  $arduino_installer
mkdir $custom_install_dir
unzip "$work_dir/arduino.zip" -d $custom_install_dir
desktop_file_content="[Desktop Entry]
Encoding=UTF-8
Version=2.3.4
Name=Arduino IDE
GenericName=Arduino IDE
Type=Application
Exec=$custom_install_dir/arduino/arduino-ide
Icon=$custom_install_dir/arduino/resources/app/resources/icons/512x512.png
Categories=Electronics;
"
desktop_file_dir="$HOME/.local/share/applications"
desktop_file="$desktop_file_dir/arduino.desktop"
echo "$desktop_file_content" > "$desktop_file"
usermod -a -G dialout $USER
usermod -a -G plugdev $USER
