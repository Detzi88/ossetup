#!/bin/bash
dash2dock_deps=("gnome-shell-extensions" "gnome-shell-extension-prefs" "jq" "wget" "unzip" "curl")


install_dash2dock(){
  BASH_BG_COLOR="#3A0C2B"
  BASH_TEXT_COLOR='rgb(211,215,207)'
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  . ${SCRIPT_DIR}/../functions.sh
  work_dir="$1"
  custom_install_dir="$2"

  if [ -z "$work_dir" ]; then
    work_dir="$SCRIPT_DIR/d2dwdir"
  fi

  if [ -z "$custom_install_dir" ]; then
    custom_install_dir="$HOME/tools/dash2dock"
  fi

  mkdir -p $work_dir
  cd $work_dir
  EXTENSION_ID="307"  # Dash to Dock ID from GNOME Extensions website
  GNOME_VERSION=$(gnome-shell --version | awk '{print $3}')  # Get GNOME Shell version

  EXT_INFO=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXTENSION_ID&shell_version=$GNOME_VERSION")
  EXT_DL_URL=$(echo "$EXT_INFO" | jq -r '.download_url')

  # Download and install the extension
  echo "Downloading Dash to Dock..."
  wget -q -O ./dash-to-dock.zip "https://extensions.gnome.org$EXT_DL_URL"
  unzip -qo dash-to-dock.zip
  EXT_UUID=$(cat $work_dir/metadata.json | grep uuid | cut -d \" -f4)
  gnome-extensions install $work_dir/dash-to-dock.zip

  rm -r $work_dir
  enabled_extensions=$(gsettings get org.gnome.shell enabled-extensions)
  disabled_extensions=$(gsettings get org.gnome.shell disabled-extensions)
  if [ "$enabled_extensions" = "@as []" ]; then
      enabled_extensions="['${EXT_UUID}']"
  else
      enabled_extensions= $(echo $enabled_extensions |sed "s/]$/, '$EXT_UUID']/")
  fi

  if [ "$disabled_extensions" = "@as []" ]; then
      disabled_extensions="[]"
  else
      #First Middle/Last Only
      enabled_extensions= $(echo $disabled_extensions |sed "s/,$EXT_UUID$//")
      enabled_extensions= $(echo $disabled_extensions |sed "s/$EXT_UUID,$//")
      enabled_extensions= $(echo $disabled_extensions |sed "s/$EXT_UUID$//")
  fi

  gsettings set org.gnome.shell disabled-extensions "$disabled_extensions"
  gsettings set org.gnome.shell enabled-extensions "$enabled_extensions"
  D2D_SCHEMADIR="$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/"
  #gsettings --schemadir $D2D_SCHEMADIR list-recursively org.gnome.shell.extensions.dash-to-dock
  gsettings --schemadir $D2D_SCHEMADIR set org.gnome.shell.extensions.dash-to-dock show-mounts false
  gsettings --schemadir $D2D_SCHEMADIR set org.gnome.shell.extensions.dash-to-dock show-trash false
  gsettings --schemadir $D2D_SCHEMADIR set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
  gsettings --schemadir $D2D_SCHEMADIR set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
  gsettings --schemadir $D2D_SCHEMADIR set org.gnome.shell.extensions.dash-to-dock apply-custom-theme true
}

