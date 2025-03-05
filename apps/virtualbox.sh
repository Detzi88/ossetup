#!/bin/bash
virtualbox_deps=()

install_virtualbox(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    VBOX_URL="https://download.virtualbox.org/virtualbox/7.1.6/virtualbox-7.1_7.1.6-167084~Debian~bookworm_amd64.deb"
    work_dir="$1"
    custom_install_dir="$2"
    if [ -z "$work_dir" ]; then
        work_dir="./vboxwork"
    fi
    install_deb_package ${VBOX_URL}
    rm "$work_dir/vbox.deb"
    sudo usermod -aG vboxusers $USER
}

