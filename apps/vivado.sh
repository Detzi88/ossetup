#!/bin/bash
vivado_deps=("graphviz" "make" "unzip" "zip" "g++" "xvfb" "git")

install_vivado(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    work_dir="$1"
    custom_install_dir="$2"

    if [ -z "$work_dir" ]; then
        work_dir="./work"
    fi
    if [ -z "$custom_install_dir" ]; then
        custom_install_dir="$HOME/tools/vivado"
    fi
    create_symlinks
}

