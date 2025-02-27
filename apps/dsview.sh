#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi

dsview_deps=("git" "gcc" "g++" "make" "cmake" "libglib2.0-dev" "zlib1g-dev" "libusb-1.0-0-dev" "libboost-dev" "libfftw3-dev" "python3-dev" "libudev-dev" "pkg-config" "qt6-base-dworkdirev" "libQt6Svg*" "libgl1-mesa-dev*" "libxkbcommon-dev" "libvulkan-dev")


for app in "${dsview_deps[@]}"; do
    log_and_install "$app" ${NOUPDATE}
    NOUPDATE="--noupdate"
done
