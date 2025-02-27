#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
vivado_deps=("graphviz" "make" "unzip" "zip" "g++" "xvfb" "git" )
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi
if [ -z "$custom_install_dir" ]; then
    custom_install_dir="$HOME/tools/vivado"
fi
create_symlinks
for app in "${vivado_deps[@]}"; do
    log_and_install "$app"
done
