#!/bin/bash
set -e  # Exit on error
BASH_BG_COLOR="#3A0C2B"
BASH_TEXT_COLOR='rgb(211,215,207)'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. ${SCRIPT_DIR}/../functions.sh
work_dir="$1"
custom_install_dir="$2"

if [ -z "$work_dir" ]; then
  work_dir="./d2dwdir"
fi

if [ -z "$custom_install_dir" ]; then
  custom_install_dir="$HOME/tools/dash2dock"
fi

mkdir $work_dir
cd $work_dir
EXTENSION_ID="307"  # Dash to Dock ID from GNOME Extensions website
GNOME_VERSION=$(gnome-shell --version | awk '{print $3}')  # Get GNOME Shell version

log_and_install gnome-shell-extensions 
log_and_install gnome-shell-extension-prefs --noupdate
log_and_install jq --noupdate
log_and_install wget --noupdate
log_and_install unzip --noupdate
log_and_install curl --noupdate

# Get user extensions directory
EXT_DIR="$HOME/.local/share/gnome-shell"
mkdir -p "$EXT_DIR/tmp"

EXT_INFO=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXTENSION_ID&shell_version=$GNOME_VERSION")
EXT_DL_URL=$(echo "$EXT_INFO" | jq -r '.download_url')

# Download and install the extension
echo "Downloading Dash to Dock..."
wget -q -O $work_dir/dash-to-dock.zip "https://extensions.gnome.org$EXT_DL_URL"
unzip -qo $work_dir/dash-to-dock.zip -d $work_dir
EXT_UUID=$(cat $EXT_DIR/metadata.json | grep uuid | cut -d \" -f4)
sudo gnome-extensions install $work_dir/dash-to-dock.zip
gnome-extensions enable $EXT_UUID
rm -r $work_dir
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    gnome-session-quit --logout --no-prompt
else
    killall -3 gnome-shell
fi
