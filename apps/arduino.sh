#!/bin/bash
arduino_deps=("curl" "unzip")

install_arduino(){
    work_dir="$1"
    custom_install_dir="$2"
    arduino_installer="https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.zip"
    if [ -z "$work_dir" ]; then
        work_dir="./arduinowork"
    fi
    mkdir -p $work_dir
    if [ -z "$custom_install_dir" ]; then
        custom_install_dir="$HOME/tools/arduino"
    fi
    curl -o "$work_dir/arduino.zip" -L  $arduino_installer
    mkdir -p $custom_install_dir
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
    sudo usermod -aG dialout $USER
    sudo usermod -aG plugdev $USER
    rm -r $work_dir
}

