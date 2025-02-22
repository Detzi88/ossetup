######################################
####use this command to run the script:
#./setupUbuntu.sh
######################################
. ./functions.sh
reboot_required=true  # or false, depending on your condition
PrusaSlicer=0
QUARTUS=0
DIAMOND=0
LTspice=0
STEAM=0
ARDUINO=0
VBOX=0
work_dir="$HOME/Downloads/setupWork"
custom_install_dir="/home/$USER/tools"
conda_prefix="$custom_install_dir/miniconda3"
arduino_installer="https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.zip"
quartus_installer="https://downloads.intel.com/akdlm/software/acdsinst/23.1std.1/993/ib_tar/Quartus-lite-23.1std.1.993-linux.tar"
#create the folder so it belongs to the user
mkdir "$work_dir"
mkdir "$custom_install_dir"
mkdir "$HOME/git"
mkdir "$HOME/svn"

#Since its quite big start the quartus download an continue with the other stuff
sudo apt install curl -y
if [[ "$QUARTUS" == "1" ]]; then
    curl -o "$work_dir/quartus.tar" -L $quartus_installer > /dev/null 2>&1 &
    CURL_PID=$!
else
    echo "QUARTUS is not set to 1, skipping."
fi



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
)
vivado_deps=("graphviz" "make" "unzip" "zip" "g++" "xvfb" "git" )
steam_deps=("libc6:amd64" "libc6:i386" "libegl1:amd64" "libegl1:i386" "libgbm1:amd64" "libgbm1:i386" "libgl1-mesa-dri:amd64" "libgl1-mesa-dri:i386" "libgl1:amd64" "libgl1:i386" "steam-libs-amd64:amd64")
dsview_deps=("git" "gcc" "g++" "make" "cmake" "libglib2.0-dev" "zlib1g-dev" "libusb-1.0-0-dev" "libboost-dev" "libfftw3-dev" "python3-dev" "libudev-dev" "pkg-config" "qt6-base-dev" "libQt6Svg*" "libgl1-mesa-dev*" "libxkbcommon-dev" "libvulkan-dev")

sudo apt update #update the package lists
sudo apt upgrade -y #install updates
sudo apt remove nvidia* -y
sudo apt autoremove -y
sudo ubuntu-drivers autoinstall #install missing drivers

if check_ubuntu_version; then
    echo "Running on Ubuntu 24.04 LTS."
    create_symlinks
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
    #Disable the show-apps Button
    gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
else
    sudo apt install -y libtinfo5
    sudo apt install -y libncurses5
    sudo apt install -y libncursesw5
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    
fi


for app in "${applications[@]}"; do
    log_and_install "$app"
done

for app in "${vivado_deps[@]}"; do
    log_and_install "$app"
done

#Wine
echo "installing wine" >>log.txt
sudo dpkg --add-architecture i386 
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo apt update 
sudo apt install --install-recommends winehq-devel -y

#steam 
if [[ "$STEAM" == "1" ]]; then
    install_deb_package https://cdn.akamai.steamstatic.com/client/installer/steam.deb
    sudo apt update
    for app in "${steam_deps[@]}"; do
        log_and_install "$app"
    done
    rm $HOME/Desktop/steam.desktop
    #let steam update in the "Background"
    steam &
else
    echo "STEAM is not set to 1, skipping."
fi


#VScode
install_deb_package https://vscode.download.prss.microsoft.com/dbazure/download/stable/fee1edb8d6d72a0ddff41e5f71a671c23ed924b9/code_1.92.2-1723660989_amd64.deb
sudo update-alternatives --install /usr/bin/gnome-text-editor gnome-text-editor /usr/bin/code 100
#obsidian
install_deb_package https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/obsidian_1.6.7_amd64.deb

#Firefox
#sudo snap remove firefox
#sudo install -d -m 0755 /etc/apt/keyrings
#wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
#gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
#echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
#echo '
#Package: *
#Pin: origin packages.mozilla.org
#Pin-Priority: 1000
#' | sudo tee /etc/apt/preferences.d/mozilla 
#sudo apt update 
#sudo apt install firefox -y

#Lattice diamond
if [[ "$DIAMOND" == "1" ]]; then
    ../installDiamond.sh
else
    echo "DIAMOND is not set to 1, skipping."
fi


#miniconda
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh >> "$work_dir/mini.sh"
chmod +x "$work_dir/mini.sh"
sudo "$work_dir/mini.sh" -b -p $conda_prefix
rm "$work_dir/mini.sh" 
#activate the auto base env
eval "$($conda_prefix/bin/conda shell.dash hook)"
conda init
#Install base python packages
pip install cocotb[bus] pytest colorama numpy scipy selenium pexpect
#Then fix the wish setup
defect="$(which wish)"
sudo mv $defect $defect.back
proper="$(which wish)"
sudo ln -s $proper $defect

#Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER


Add File templates to your templates folder
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

#set the grub default timeout to something reasonable and hide it:
sudo sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1\n#/g' /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=1" | sudo tee -a /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" | sudo tee -a /etc/default/grub
update-grub

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

#remov the speech dispatcher (audio crackling issue)
sudo apt remove speech-dispatcher -y
sudo systemctl disable speech-dispatcherd
sudo systemctl disable speech-dispatcher
sudo systemctl stop speech-dispatcherd
sudo systemctl stop speech-dispatcher

#remove outdated packages
sudo apt autoremove -y

#Prusa Slicer
if [[ "$PrusaSlicer" == "1" ]]; then
    #Flatpak is now the official way to do it.
    sudo apt install flatpak -y
    sudo apt install gnome-software-plugin-flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install flathub com.prusa3d.PrusaSlicer -y
    #curl -o "$work_dir/prusa.zip" -L  https://cdn.prusa3d.com/downloads/drivers/prusa3d_linux_2_8_0.zip
    #unzip "$work_dir/prusa.zip" -d $custom_install_dir/prusa
    #chmod +x $custom_install_dir/prusa/*Ubuntu-24-04.AppImage
    #find $custom_install_dir/prusa -type f ! -name '*Ubuntu-24-04.AppImage' -delete
    #mv $custom_install_dir/prusa/*Ubuntu-24-04.AppImage $custom_install_dir/prusa/slicer.AppImage
    #rm "$work_dir/prusa.zip" 

    #desktop_file_content="[Desktop Entry]
    #Encoding=UTF-8
    #Version=1.0
    #Name=Prusa Slicer
    #GenericName=Prusa Slicer
    #Type=Application
    #Exec=$custom_install_dir/prusa/slicer.AppImage
    #Icon=$custom_install_dir/prusa/slicer.AppImage
    #Categories=Electronics;
    #"
    #desktop_file_dir="$HOME/.local/share/applications"
    #desktop_file="$desktop_file_dir/prusa.desktop"
    #echo "$desktop_file_content" > "$desktop_file"
else
    echo "DIAMOND is not set to 1, skipping."
fi


#Arduino
if [[ "$ARDUINO" == "1" ]]; then
    curl -o "$work_dir/arduino.zip" -L  $arduino_installer
    mkdir $custom_install_dir/arduino
    unzip "$work_dir/arduino.zip" -d $custom_install_dir/arduino
    desktop_file_content="[Desktop Entry]
    Encoding=UTF-8
    Version=2.3.4
    Name=Arduino IDE
    GenericName=Arduino IDE
    Type=Application
    Exec=$custom_install_dir/arduino/arduino-ide
    Icon=$custom_install_dir/arduino/resources/app/resources/icons/512x512.png
    Categories=Electronics;
    "
    desktop_file_dir="$HOME/.local/share/applications"
    desktop_file="$desktop_file_dir/arduino.desktop"
    echo "$desktop_file_content" > "$desktop_file"
else
    echo "ARDUINO is not set to 1, skipping."
fi



#add aliases and Paths to the bashrc
echo "alias gg='git gui'" | tee -a ~/.bashrc
echo "export LM_LICENSE_FILE=\"$custom_install_dir/lscc/diamond/3.13/license:\$LM_LICENSE_FILE\"" | tee -a ~/.bashrc
echo "export PATH=\"$custom_install_dir/intel/questa_fse/linux_x86_64:\$PATH\"" | tee -a ~/.bashrc
echo "export LM_LICENSE_FILE=\"$custom_install_dir/intel/licenses/LR-182130_License.dat:\$LM_LICENSE_FILE\"" | tee -a ~/.bashrc

#Wait for the quartus download to finish then continue
if [[ "$QUARTUS" == "1" ]]; then
    mkdir "$work_dir/intel"
    wait $CURL_PID
    tar -xvf "$work_dir/quartus.tar" -C "$work_dir/intel"
    "$work_dir/intel/components/QuartusLiteSetup-23.1std.1.993-linux.run" --mode unattended \
        --installdir $custom_install_dir/intel \
        --create_desktop_shortcuts 1 \
        --accept_eula 1 
    rm -r "$work_dir/intel"
    rm "$work_dir/quartus.tar"
    # Install the "rules" for the 
    quartus_file="/etc/udev/rules.d/51-usbblaster.rules"
    echo '# Intel FPGA Download Cable' | sudo tee  "$quartus_file"
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"'    | sudo tee -a "$quartus_file"
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"'    | sudo tee -a "$quartus_file"
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"'    | sudo tee -a "$quartus_file"
    echo '# Intel FPGA Download Cable II'    | sudo tee -a "$quartus_file"
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"'    | sudo tee -a "$quartus_file"
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"'    | sudo tee -a "$quartus_file"
else
    echo "QUARTUS is not set to 1, skipping."
fi



#Virtualbox also requires user interaction if secureboot is enabled
if [[ "$VBOX" == "1" ]]; then
    echo "installing virtualbox" >>log.txt
    curl -o "$work_dir/vbox.deb" -L "https://download.virtualbox.org/virtualbox/7.0.20/virtualbox-7.0_7.0.20-163906~Ubuntu~noble_amd64.deb"
    sudo apt install "$work_dir/vbox.deb" -y
    rm "$work_dir/vbox.deb"
    usermod -a -G vboxusers $USER
else
    echo "VBOX is not set to 1, skipping."
fi


#for serial port access
usermod -a -G dialout $USER

#LTspice
if [[ "$LTspice" == "1" ]]; then
    #This is last because it needs user interaction
    install_wine_package https://ltspice.analog.com/software/LTspiceXVII.exe LTspiceXVII
    #Configure wine with the specified prefix
    #"LogPixels"=dword:000000c0 in user.reg
    WINEARCH=win32 WINEPREFIX="$custom_install_dir/LTspiceXVII/" winecfg settings dpi=196
else
    echo "LTspice is not set to 1, skipping."
fi


#Move all shortcuts to their proper location and then clean up
chmod +x $HOME/Desktop/*.desktop
mv $HOME/Desktop/*.desktop $desktop_file_dir/
rm $HOME/Desktop/*
rm -r "$work_dir"
if [ "$reboot_required" = true ]; then
    reboot
fi
# echo "installing Flatpak" >>log.txt
# apt install flatpak -y
# apt install gnome-software-plugin-flatpak -y
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# echo "installing MakeMKV">>log.txt
# flatpak install flathub com.makemkv.MakeMKV -y
