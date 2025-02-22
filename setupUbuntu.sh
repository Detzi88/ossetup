######################################
####use this command to run the script:
#./setupUbuntu.sh
######################################
. ./functions.sh
reboot_required=true  # or false, depending on your condition
QUARTUS=0
WINE=0
STEAM=0
DIAMOND=0
LTspice=0
VBOX=0
DSView=0
CODE=0
MINICONDA=0
DOCKER=0
VIVADO=0
PrusaSlicer=0
ARDUINO=0

work_dir="$HOME/Downloads/setupWork"
custom_install_dir="/home/$USER/tools"

#store the pids of background tasks
pids=()
#create the default folders so they belong to the user
mkdir -p "$work_dir"
mkdir -p "$custom_install_dir"
mkdir .p "$HOME/git"
mkdir -p "$HOME/svn"

# I need curl for all the background downloads to work so install it first:
sudo apt install curl -y

applications=(  "build-essential" 
                "net-tools" 
                "rpm2cpio" 
                "ripgrep" 
                "rpm" 
                "network-manager-vpnc" 
                "vpnc" 
                "default-jre"
                "winetricks"
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
)

#Quartus
install_custom_app  $work_dir "quartus" $QUARTUS $custom_install_dir/intel & pids+=($!)
#Wine
install_custom_app "$work_dir" "wine" $WINE "$custom_install_dir/wine" & pids+=($!)
#steam 
install_custom_app $work_dir "steam" $STEAM "$custom_install_dir/steam" & pids+=($!)
#Lattice diamond
install_custom_app $work_dir "diamond" $DIAMOND "$HOME/tools/lscc" & pids+=($!)
#LTspiceXVII
install_custom_app $work_dir "LTspice" $LTspice "$HOME/tools/LTspiceXVII" & pids+=($!)
#DSView
install_custom_app $work_dir "dsview" $DSView "$HOME/tools/dsview" & pids+=($!)
#Virtualbox also requires user interaction if secureboot is enabled
install_custom_app $work_dir "virtualbox" $VBOX "$HOME/tools/vbox" & pids+=($!)
#VScode
install_custom_app  $work_dir "code" $CODE "$custom_install_dir/code" & pids+=($!)
#miniconda
install_custom_app  $work_dir "miniconda" $MINICONDA "$HOME/tools/miniconda3" & pids+=($!)
#Docker
install_custom_app  $work_dir "docker" $DOCKER "$HOME/tools/docker" & pids+=($!)
#Vivado
install_custom_app  $work_dir "vivado" $VIVADO "$HOME/tools/xilinx" & pids+=($!)
#Prusa Slic3r
install_custom_app  $work_dir "prusasclic3r" $PrusaSlicer "$HOME/tools/prusa" & pids+=($!)
#Arduino
install_custom_app  $work_dir "arduino" $ARDUINO "$HOME/tools/arduino" & pids+=($!)


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
#Disable the show-apps Button and do other customisations
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.desktop.notifications show-banners false
#I still need to manually adjust the dock behaviour. Auto hide does not work, neither does hiding volumes devices and trash 
#Set my shortcuts
set_custom_keybinding "custom0" "Terminal" "gnome-terminal" "<Super>t"
set_custom_keybinding "custom1" "Task Manager" "gnome-system-monitor" "<Primary><Shift>Escape"
set_custom_keybinding "custom2" "Firefox" "firefox" "<Super>f"
set_custom_keybinding "custom3" "Nautilus" "nautilus" "<Super>x"
set_custom_keybinding "custom4" "Set Monitors" "/home/$USER/Nextcloud/Documents/Projekte/LinuxSetup/Setup/monitors/hdmi-mirror.sh" "<Super>d"
#set the grub default timeout to something reasonable and hide it:
sudo sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1\n#/g' /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=1" | sudo tee -a /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" | sudo tee -a /etc/default/grub
update-grub
#add aliases and Paths to the bashrc
echo "alias gg='git gui'" | tee -a ~/.bashrc
echo "export LM_LICENSE_FILE=\"$custom_install_dir/lscc/diamond/3.13/license:\$LM_LICENSE_FILE\"" | tee -a ~/.bashrc
echo "export PATH=\"$custom_install_dir/intel/questa_fse/linux_x86_64:\$PATH\"" | tee -a ~/.bashrc
echo "export LM_LICENSE_FILE=\"$custom_install_dir/intel/licenses/LR-182130_License.dat:\$LM_LICENSE_FILE\"" | tee -a ~/.bashrc
#for serial port access
usermod -a -G dialout $USER
usermod -a -G plugdev $USER


### Install my Applications
wait_for_apt_lock
sudo apt update #update the package lists
sudo apt upgrade -y #install updates
sudo apt remove nvidia* -y
sudo apt autoremove -y
sudo ubuntu-drivers autoinstall #install missing drivers
for app in "${applications[@]}"; do
    log_and_install "$app"
done
#obsidian
install_deb_package https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.7/obsidian_1.8.7_amd64.deb
#remove the speech dispatcher (audio crackling issue)
sudo apt remove speech-dispatcher -y
sudo systemctl disable speech-dispatcherd
sudo systemctl disable speech-dispatcher
sudo systemctl stop speech-dispatcherd
sudo systemctl stop speech-dispatcher

### CLEANUP
#wait for the spawned tasks to finish:
for pid in "${pids[@]}"; do
    wait "$pid"
done
#Move all shortcuts to their proper location and then clean up
chmod +x $HOME/Desktop/*.desktop
mv $HOME/Desktop/*.desktop $desktop_file_dir/
rm $HOME/Desktop/*
sudo apt autoremove -y
rm -r "$work_dir"
if [ "$reboot_required" = true ]; then
    reboot
fi
