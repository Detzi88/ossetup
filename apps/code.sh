#!/bin/bash
install_code(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    
    if [ "$(uname -m)" = "aarch64" ]; then
        codelink=https://vscode.download.prss.microsoft.com/dbazure/download/stable/e54c774e0add60467559eb0d1e229c6452cf8447/code_1.97.2-1739406006_arm64.deb
    else
        codelink=https://vscode.download.prss.microsoft.com/dbazure/download/stable/fee1edb8d6d72a0ddff41e5f71a671c23ed924b9/code_1.92.2-1723660989_amd64.deb
    fi

    install_deb_package ${codelink}
    sudo update-alternatives --install /usr/bin/gnome-text-editor gnome-text-editor /usr/bin/code 100
}