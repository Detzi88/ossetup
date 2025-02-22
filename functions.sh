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

install_deb_package() {
    # Check if the URL is provided
    if [ -z "$1" ]; then
        echo "Usage: install_deb_package <download_link>"
        return 1
    fi
    # Assign the first argument to a variable
    local download_link=$1
    # Define the file name for the downloaded package
    local file_name="package.deb"
    # Download the file
    curl -o "$file_name" -L "$download_link"
    # Install the downloaded package
    sudo apt install -y ./"$file_name"
    # Remove the downloaded .deb file
    rm "$file_name"
    echo "Installation completed and $file_name file removed."
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

log_and_install() {
    echo "installing $1" >>log.txt && sudo apt install "$1" -y
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