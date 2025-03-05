#!/bin/bash
themes_deps=("libgtk-3-dev" "git" "meson" "sassc")

install_themes(){
  BASH_BG_COLOR="#3A0C2B"
  BASH_TEXT_COLOR='rgb(211,215,207)'
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  . ${SCRIPT_DIR}/../functions.sh
  work_dir="$1"
  custom_install_dir="$2"

  if [ -z "$work_dir" ]; then
    work_dir="$HOME/yaruwdir"
  fi

  if [ -z "$custom_install_dir" ]; then
    custom_install_dir="$HOME/tools"
  fi

  if [ "$(DISTRO_ID)" = "Ubuntu" ]; then
    #dock auto hide , hiding volumes devices and trash
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false 
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
  else
    sdir=$(pwd)
    mkdir -p $custom_install_dir
    cd $custom_install_dir
    git clone https://github.com/ubuntu/yaru.git
    cd yaru
    # Initialize build system (only required once per repo)
    meson build
    cd build
    # Build and install
    sudo ninja install
    cd $sdir
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
}

