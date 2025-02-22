#!/bin/bash
. ../functions.sh
work_dir="$1"
custom_install_dir="$2"
vivado_deps=("graphviz" "make" "unzip" "zip" "g++" "xvfb" "git" )
create_symlinks
wait_for_apt_lock
for app in "${vivado_deps[@]}"; do
    log_and_install "$app"
done
