#!/bin/bash
dsview_deps=("git" "gcc" "g++" "make" "cmake" "libglib2.0-dev" "zlib1g-dev" "libusb-1.0-0-dev" \
             "libboost-dev" "libfftw3-dev" "python3-dev" "libudev-dev" "pkg-config" "qt6-base-dev" \
             "libQt6Svg*" "libgl1-mesa-dev*" "libxkbcommon-dev" "libvulkan-dev")

install_dsview(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    work_dir="$1"
    custom_install_dir="$2"
}
