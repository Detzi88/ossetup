######################################
####use this command to run the script:
#./runSetup.sh
######################################
#!/bin/bash
######################################
#CUSTOMIZE SPECIAL APPs
######################################
QUARTUS=1
WINE=1
STEAM=1
DIAMOND=1
LTspice=1
VBOX=1
DSView=1
CODE=1
MINICONDA=1
DOCKER=1
VIVADO=1
PrusaSlicer=1
ARDUINO=1
OBSIDIAN=1
THEMES=1
DASH2DOCK=1
#######################################
#######################################
BASH_BG_COLOR="#3A0C2B"
BASH_TEXT_COLOR='rgb(211,215,207)'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. ${SCRIPT_DIR}/functions.sh
work_dir="$1"
custom_install_dir="$2"

if [ -z "${work_dir}" ]; then
  work_dir="$HOME/Downloads/setupWork"
fi

if [ -z "$custom_install_dir" ]; then
  custom_install_dir="/home/$USER/tools"
fi

#Dash 2 dock is currently the only package requirering a reboot
if [[ $DASH2DOCK -eq 1 || $PrusaSlicer -eq 1 ]]; then
  reboot_required=true
else
  reboot_required=false
fi

#store the pids of background tasks
pids=()
DISTRO_ID=$(lsb_release -si)
#create the default folders so they belong to the user
mkdir -p "${work_dir}"
mkdir -p "$custom_install_dir"
mkdir -p "$HOME/git"
#mkdir -p "$HOME/svn"
mkdir -p ${SCRIPT_DIR}/logs

#Disable idle sleep while installing
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery false
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# I need curl for all the background downloads to work so install it first:
log_and_install curl 
sudo dpkg --add-architecture i386

applications=(  "build-essential" 
                "net-tools" 
                "rpm2cpio" 
                "ripgrep" 
                "rpm" 
                "network-manager-vpnc" 
                "vpnc" 
                "default-jre"
                "kicad"
                "texlive"
                "texstudio" 
                "git"
                "rabbitvcs-nautilus"
                "handbrake"
                "subversion"
                "nextcloud-desktop"
                "git-gui"
                "p7zip"
                "samba"
                "sigrok"
                "keepassxc"
                "texlive-lang-german"
                "libavcodec-extra"
                "ffmpeg"
                "remmina"
                "inkscape"
                "gimp"
                "winbind"
                "network-manager-openvpn"
                "gtkwave"
                "ghdl"
                "chrome-gnome-shell"
                "pavucontrol"
                "paprefs"
                "opensc"
                "gnutls-bin"
                "gcc-12"
                "linux-headers-$(uname -r)"
                "dkms"
                "dconf-editor"
                "dconf-cli"
                "lm-sensors"
                "network-manager-vpnc-gnome"
                "wget"
                "gnome-tweaks"
                "wireguard"
                "gparted"
                "libreoffice"
                "smbclient" 
                "cifs-utils"
                "sysbench"
                "usb-creator-gtk"
                "libtinfo5"
                "libncurses5"
                "libncursesw5"
                "graphviz" 
                "make" 
                "unzip" 
                "zip" 
                "g++" 
                "xvfb" 
                "tftpd" 
                "tftp"
                "firmware-linux"
)

custom_apps=()

if [ $QUARTUS -eq 1 ]; then 
  source ./apps/quartus.sh
  applications+=("${quartus_deps[@]}")
  download_quartus & pids+=($!)
  custom_apps+=("quartus")
fi

if [ $DIAMOND -eq 1 ]; then 
  source ./apps/diamond.sh
  applications+=("${diamond_deps[@]}")
  download_diamond & pids+=($!)
  custom_apps+=("diamond")
fi

if [ $STEAM -eq 1 ]; then 
  source ./apps/steam.sh
  applications+=("${steam_deps[@]}")
  custom_apps+=("steam")
fi

if [ $WINE -eq 1 ]; then 
  source ./apps/wine.sh
  applications+=("${wine_deps[@]}")
  custom_apps+=("wine")
fi

if [ $LTspice -eq 1 ]; then 
  source ./apps/LTspice.sh
  applications+=("${LTspice_deps[@]}")
  custom_apps+=("LTspice")
fi

if [ $DSView -eq 1 ]; then 
  source ./apps/dsview.sh
  applications+=("${dsview_deps[@]}")
  custom_apps+=("dsview")
fi

if [ $VBOX -eq 1 ]; then 
  source ./apps/virtualbox.sh
  applications+=("${virtualbox_deps[@]}")
  custom_apps+=("virtualbox")
fi

if [ $CODE -eq 1 ]; then 
  source ./apps/code.sh
  applications+=("${code_deps[@]}")
  custom_apps+=("code")
fi

if [ $MINICONDA -eq 1 ]; then 
  source ./apps/miniconda.sh
  applications+=("${miniconda_deps[@]}")
  custom_apps+=("miniconda")
fi

if [ $DOCKER -eq 1 ]; then 
  source ./apps/docker.sh
  applications+=("${docker_deps[@]}")
  custom_apps+=("docker")
fi

if [ $VIVADO -eq 1 ]; then 
  source ./apps/vivado.sh
  applications+=("${vivado_deps[@]}")
  custom_apps+=("vivado")
fi

if [ $PrusaSlicer -eq 1 ]; then 
  source ./apps/prusaslic3r.sh
  applications+=("${prusaslic3r_deps[@]}")
  custom_apps+=("prusaslic3r")
fi

if [ $ARDUINO -eq 1 ]; then 
  source ./apps/arduino.sh
  applications+=("${arduino_deps[@]}")
  custom_apps+=("arduino")
fi

if [ $OBSIDIAN -eq 1 ]; then 
  source ./apps/obsidian.sh
  applications+=("${obsidian_deps[@]}")
  custom_apps+=("obsidian")
fi

if [ $DASH2DOCK -eq 1 ]; then 
  source ./apps/dash2dock.sh
  applications+=("${dash2dock_deps[@]}")
  custom_apps+=("dash2dock")
fi

if [ $THEMES -eq 1 ]; then 
  source ./apps/themes.sh
  applications+=("${themes_deps[@]}")
  custom_apps+=("themes")
fi

##########################################
###CUSTOMIZE THE OS
##########################################

#Add File templates to your templates folder
mkdir /home/$USER/Templates/
touch /home/$USER/Templates/python3.py
touch /home/$USER/Templates/cppHeader.h
touch /home/$USER/Templates/cppSource.cpp
touch /home/$USER/Templates/shellSkript.sh
touch /home/$USER/Templates/VHDL.vhd
touch /home/$USER/Templates/verilog.v
touch /home/$USER/Templates/text.txt
touch /home/$USER/Templates/Readme.md
touch /home/$USER/Templates/Makefile

#Set my shortcuts
set_custom_keybinding "custom0" "Terminal" "gnome-terminal" "<Super>t"
set_custom_keybinding "custom1" "Task Manager" "gnome-system-monitor" "<Primary><Shift>Escape"
set_custom_keybinding "custom2" "Firefox" "firefox" "<Super>f"
set_custom_keybinding "custom3" "Nautilus" "nautilus" "<Super>x"
set_custom_keybinding "custom4" "Set Monitors" "$HOME/Nextcloud/Documents/Projekte/LinuxSetup/Setup/monitors/hdmi-mirror.sh" "<Super>d"

#Customize Gnomegsettings set org.gnome.desktop.session idle-delay uint32 480
gsettings set org.gnome.desktop.peripherals.mouse double-click 400
gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.desktop.session idle-delay 480
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1200
gsettings set org.gnome.desktop.interface show-battery-percentage true

if [ "$DISTRO_ID" = "Ubuntu" ]; then
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
  gsettings set org.gnome.shell.extensions.ding show-home false
fi
gsettings set org.gnome.desktop.notifications show-banners false
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'org.gnome.Nautilus.desktop']"
 
#set the grub default timeout to something reasonable and hide it:
sudo sed -i -e 's/GaarRUB_TIMEOUT=10/GRUB_TIMEOUT=1\n#/g' /etc/default/grub
#If on the arm add the cutmem. But this should already be done whilst in the live session.
if [ "$(uname -m)" = "aarch64" ]; then
    sudo sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cutmem 0x8800000000 0x8fffffffff"#/g' /etc/default/grub
fi
echo "GRUB_HIDDEN_TIMEOUT_QUIET=1" | sudo tee -a /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" | sudo tee -a /etc/default/grub
sudo update-grub

#add aliases and Paths to the bashrc
echo "alias gg='git gui'" | tee -a ~/.bashrc
echo "export LM_LICENSE_FILE=\"$custom_install_dir/lscc/diamond/3.13/license:\$LM_LICENSE_FILE\"" | tee -a ~/.bashrc
echo "export PATH=\"$custom_install_dir/intel/questa_fse/linux_x86_64:\$PATH\"" | tee -a ~/.bashrc
echo "export LM_LICENSE_FILE=\"$custom_install_dir/intel/licenses/LR-182130_License.dat:\$LM_LICENSE_FILE\"" | tee -a ~/.bashrc
#for serial port access
sudo usermod -a -G dialout $USER
sudo usermod -a -G plugdev $USER

### Install my Applications
sudo apt-get update
sudo apt-get upgrade -y 
sudo apt-get remove nvidia*
sudo apt-get autoremove

#echo "Installing missing drivers:"
if [ "$DISTRO_ID" = "Ubuntu" ]; then
  sudo ubuntu-drivers autoinstall
fi

applications_sorted=($(printf "%s\n" "${applications[@]}" | sort -u))
echo $applications_sorted

for app in "${applications_sorted[@]}"; do
    sudo apt install "$app" -y
    echo $app
done

#remove the speech dispatcher (audio crackling issue)
sudo apt-get remove speech-dispatcher -y
sudo systemctl disable speech-dispatcherd
sudo systemctl disable speech-dispatcher
sudo systemctl stop speech-dispatcherd
sudo systemctl stop speech-dispatcher

##########################################
### Install custom Apps
##########################################
#wait for the downloads to finish:
for pid in "${pids[@]}"; do
    wait "$pid"
done

for app in "${custom_apps[@]}"; do
    #echo "install_${app}"
    install_${app}
done
##########################################
### CLEANUP
##########################################
#Move all shortcuts to their proper location and then clean up
chmod +x $HOME/Desktop/*.desktop
mv $HOME/Desktop/*.desktop $desktop_file_dir/
rm $HOME/Desktop/*
sudo apt-get autoremove -y
sudo apt-get update
sudo rm -r "${work_dir}"
#Enable Idle Sleep
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
if [ "$reboot_required" = true ]; then
    #sudo shutdown -r now
fi
