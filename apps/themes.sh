#!/bin/bash
BASH_BG_COLOR="#3A0C2B"
BASH_TEXT_COLOR='rgb(211,215,207)'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. ${SCRIPT_DIR}/../functions.sh
work_dir="$1"
custom_install_dir="$2"

if [ -z "$work_dir" ]; then
  work_dir="./yaruwdir"
fi

if [ -z "$custom_install_dir" ]; then
  custom_install_dir="$HOME/tools/yaru"
fi

# THEME_LINK="https://www.dropbox.com/scl/fo/6oy64dvfftj7bp8lhs1jw/AM3Ew5kEa7xqRk3CT4BcY0E?rlkey=2gr0c3j9e36wpg60rsh8wl2a2&st=iiv2koav&dl=1"
# log_and_install curl
# log_and_install unzip
# mkdir ${SCRIPT_DIR}/themes
# curl -L -o "${SCRIPT_DIR}/themes.zip" ${THEME_LINK}
# unzip ${SCRIPT_DIR}/themes.zip -d ${SCRIPT_DIR}/themes
# sudo cp -rn ${SCRIPT_DIR}/themes/* /usr/share/themes/
if [ "$(DISTRO_ID)" = "Ubuntu" ]; then
  #dock auto hide , hiding volumes devices and trash
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false 
  gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
  gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
  gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
else
    log_and_install libgtk-3-dev 
    log_and_install git --noupdate
    log_and_install meson --noupdate
    log_and_install sassc --noupdate
    cd $work_dir
    git clone https://github.com/ubuntu/yaru.git
    cd yaru
    # Initialize build system (only required once per repo)
    meson build
    cd build
    # Build and install
    sudo ninja install
fi
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-purple-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-purple-dark'
#gsettings list-keys org.gnome.Terminal.Legacy.Profile
THEMEID=$(gsettings get org.gnome.Terminal.ProfilesList list)
THEMEID=$( echo ${THEMEID}|tr -d "[]'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${THEMEID}/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${THEMEID}/ foreground-color ${BASH_TEXT_COLOR}
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${THEMEID}/ background-color ${BASH_BG_COLOR}

