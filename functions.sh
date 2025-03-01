# Define color variables
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESETCOLOR="\e[0m"   # Resets text color
check_ubuntu_version() {
    local version
    version=$(lsb_release -r | awk '{print $2}')
    if [[ "$version" == "24.04" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to create symbolic links
create_symlinks() {
    local libtinfo_path
    local libncurses_path
    local libncursesw_path

    # Find the location of libtinfo.so.6 and libncurses.so.6
    libtinfo_path=$(whereis libtinfo.so.6 | awk '{print $2}')
    libncurses_path=$(whereis libncurses.so.6 | awk '{print $2}')
    libncursesw_path=$(whereis libncursesw.so.6 | awk '{print $2}')

    if [[ -z "$libtinfo_path" || -z "$libncurses_path" || -z "$libncursesw_path" ]]; then
        echo "One or all libraries not found."
        exit 1
    fi

    # Create symbolic links
    sudo ln -sf "$libtinfo_path" "$(dirname "$libtinfo_path")/libtinfo.so.5"
    sudo ln -sf "$libncurses_path" "$(dirname "$libncurses_path")/libncurses.so.5"
    sudo ln -sf "$libncursesw_path" "$(dirname "$libncursesw_path")/libncursesw.so.5"

    echo "Symbolic links created:"
    echo "$(dirname "$libtinfo_path")/libtinfo.so.5 -> $libtinfo_path"
    echo "$(dirname "$libncurses_path")/libncurses.so.5 -> $libncurses_path"
    echo "$(dirname "$libncursesw_path")/libncursesw.so.5 -> $libncursesw_path"
}

install_wine_package() {
    # Check if the URL and bottle name are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: install_wine_package <download_link> <bottle_name>"
        return 1
    fi

    # Assign arguments to variables
    local download_link=$1
    local bottle_name=$2
    local username=$(whoami)
    local file_name="wine_package.exe"

    # Download the file
    curl -o "$file_name" -L "$download_link"

    # Create directory structure for the wine bottle
    mkdir -p "/home/$username/tools/$bottle_name"
    chown -R "$username:$username" "/home/$username/tools"

    # Configure wine with the specified prefix
    # WINEARCH=win32 WINEPREFIX="/home/$username/tools/$bottle_name/" winecfg -q 

    # Run the installer using wine
    WINEPREFIX="/home/$username/tools/$bottle_name/" wine "./$file_name"

    # Remove the downloaded installer
    rm "./$file_name"

    echo "Installation completed and $file_name removed."
}

set_custom_keybinding() {
    local custom=$1
    local name=$2
    local command=$3
    local binding=$4

    # Set the custom keybinding
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$custom/ name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$custom/ command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$custom/ binding "$binding"

    # Prepare the new path
    local new_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$custom/"

    # Read the current array of custom keybinding paths
    local current_bindings=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings | tr -d '[]' | tr ',' '\n')

    # Check if the new path is already in the array
    local found=false
    for path in $current_bindings; do
        if [[ "'$new_path'" == "$path" ]]; then
            found=true
            break
        fi
    done

    # If the new path is not in the array, add it
    if [ "$found" = false ]; then
        if [ -z "$current_bindings" ]; then
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['$new_path']"
        else
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "[$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings | tr -d '[]') , '$new_path']"
        fi
    fi
}

install_custom_app() {
	if [ "$#" -lt 3 ]; then
        	echo "Usage: install_custom_app <work_dir 'Path'> <name 'string'> <install '0/1'> optional: <target 'Path'>"
        	echo "Example: install_custom_app \$workdir virtualbox 1 /home/me/tools"
        	return 1
   	fi
   	local work_dir="$1"
	local NAME="$2"
	local INSTALL="$3"
	local target_path="$4"
	
	if [ -z "$target_path" ]; then
	    target_path="$HOME/tools/unknown"
	fi

	if [[ "$INSTALL" == "1" && -f ./apps/$NAME.sh ]]; then
	    ./apps/${NAME}.sh $work_dir $target_path >> ./logs/${NAME}.log 2>&1
	    echo -e "Installing ${CYAN}$NAME${RESETCOLOR} ${GREEN}done${RESETCOLOR}."
	else
	    echo -e "${YELLOW}Skipping${RESETCOLOR} ${CYAN}${NAME}${RESETCOLOR}.It is either not selected, or ./apps/$NAME.sh does not exist ."
	fi
}


log_and_install() {
   # wait_for_apt_lock
    UPDATE=1
    RETRY_TIMEOUT=5
    mkdir -p ./logs

    for arg in "$@"; do
        if [ "$arg" = "--noupdate" ]; then
            UPDATE=0
            break  # Stop checking once found
        fi
    done

    if [ "$UPDATE" = "1" ]; then
        while ! sudo apt-get -o DPkg::Lock::Timeout=3600 update; do
        sleep $RETRY_TIMEOUT
        done
    fi
        
    echo "installing $1" >> deblog.log
    while ! sudo apt-get -o DPkg::Lock::Timeout=3600 install "$1" -y >>./logs/$1.log 2>&1 ; do 
        sleep $RETRY_TIMEOUT 
    done 
}

install_deb_package() {
    # Check if the URL is provided
    RETRY_TIMEOUT=5
    if [ -z "$1" ]; then
        echo "Usage: install_deb_package <download_link>"
        return 1
    fi
    # Assign the first argument to a variable
    local download_link=${1}
    domain=$(echo ${download_link} | awk -F[/:] '{print $4}')
    # Define the file name for the downloaded package
    local file_name="${domain}.deb"
    # Download the file
    curl -o "$file_name" -L "$download_link"
    # Install the downloaded package
    #wait_for_apt_lock
    while ! sudo apt-get -o DPkg::Lock::Timeout=3600 install -y ./"$file_name" ; do 
        sleep $RETRY_TIMEOUT 
    done
    # Remove the downloaded .deb file
    rm "$file_name"
}
