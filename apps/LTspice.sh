#!/bin/bash
install_LTspice(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    work_dir="$1"
    custom_install_dir="$2"
    install_wine_package https://ltspice.analog.com/software/LTspiceXVII.exe LTspiceXVII
    WINEARCH=win32 WINEPREFIX="$custom_install_dir" winecfg settings dpi=196
}
