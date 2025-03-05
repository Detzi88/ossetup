#!/bin/bash
diamond_deps=("curl" "rpm2cpio" "cpio" "libusb-0.1-4" "rpm" "sed" "libxft2:i386" "libxtst6" "libsm6" \
              "libxrender1" "libxext6" "libstdc++6" "libglib2.0-0:i386" "libgdk-pixbuf2.0-0:i386" \
              "libgtk2.0-0:i386" "libcanberra-gtk-module:i386" "libcanberra-gtk3-module:i386")
#$SUDO dpkg --add-architecture i386

download_diamond(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    workdir="$1"
    install_dir="$2"
    #Aarch64 is not supported
    if [ "$(uname -m)" = "aarch64" ]; then
        echo "No installation candidates for aarch64"
        exit 1
    fi
    if [ -z "$workdir" ]; then
        workdir="${HOME}/diamondwork"
    fi
    mkdir -p ${workdir}
    lattice_file_link="https://files.latticesemi.com/Diamond/3.13/diamond_3_13-base-56-2-x86_64-linux.rpm"
    lattice_encryption_link="https://www.latticesemi.com/-/media/LatticeSemi/Documents/DownloadableSoftware/Encryption/diamond_3_13-encryption_security-56-2-x86_64-linux.ashx"
    mico_system_link="https://files.latticesemi.com/Diamond/3.13/lms_1_2_for_diamond3_13.rpm"

    curl_header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"
    current_dir=$PWD
    cd ${workdir}

    curl -o ${workdir}/diamond_base.rpm -L $lattice_file_link > /dev/null 2>&1 &
    DMD_CURL_PID=$!

    curl -o ${workdir}/encryption_pack.rpm -L -H "$curl_header" "$lattice_encryption_link" > /dev/null 2>&1 &
    ENC_CURL_PID=$!

    curl -o ${workdir}/lms.rpm -L -H "$curl_header" "$mico_system_link" > /dev/null 2>&1 &
    LMS_CURL_PID=$!

    wait $DMD_CURL_PID
    wait $ENC_CURL_PID
    wait $LMS_CURL_PID
}

install_diamond(){
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    . ${SCRIPT_DIR}/../functions.sh
    workdir="$1"
    install_dir="$2"
    #Aarch64 is not supported
    if [ "$(uname -m)" = "aarch64" ]; then
        echo "No installation candidates for aarch64"
        exit 1
    fi
    if [ -z "$workdir" ]; then
        workdir="${HOME}/diamondwork"
    fi
    mkdir -p ${workdir}
    #Put this into the same path as the downloaded .rpm file.
    #adjust the two following parameters as needed:
    # Define install path
    # If not root, use $SUDO
    if [ "$UID" -ne 0 ]; then SUDO="sudo"; else SUDO=""; fi
    lattice_version="3.13"
    #provide a license if you got one
    node_lock_license_file="$(pwd)/license.dat"
    usb_programmer_rules_file="/etc/udev/rules.d/71-lattice.rules"
    
    # Define the directory and filename for the .desktop file
    desktop_file_dir="$HOME/.local/share/applications"
    desktop_file="$desktop_file_dir/diamond.desktop"
    synp_desktop_file="$desktop_file_dir/synp.desktop"
    lms_desktop_file="$desktop_file_dir/lms.desktop"
    synplify_pro_wrapper="$install_dir/diamond/${lattice_version}/bin/lin64/synplifyPro"

    # Define the content of the .desktop file, using install_dir for the Exec path
    # Maybe use LogoThin.png$install_dir/
    desktop_file_content="[Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Name=Lattice Diamond
    GenericName=Launch Lattice Diamond
    Type=Application
    Exec=$install_dir/diamond/$lattice_version/bin/lin64/diamond
    Icon=$install_dir/diamond/$lattice_version/docs/webhelp/eng/connect/Lattice_Icon.ico
    Categories=Electronics;
    "

    #Install Diamond
    mkdir -p ${workdir}/diamond
    mv diamond_base.rpm diamond
    cd ${workdir}/diamond
    postinst_script="${workdir}/diamond/postinst.sh"
    # Make sure the postinst.sh is empty or create it if it doesn't exist
    > "$postinst_script"
    rpm2cpio *.rpm | cpio -idmv
    rpm -qp --scripts *.rpm | grep '^cd' >> "$postinst_script"
    export RPM_INSTALL_PREFIX="$(pwd)/usr/local"
    # Make postinst.sh executable
    chmod +x "$postinst_script"
    # Run postinst.sh
    "$postinst_script"
    mkdir -p "$install_dir"
    # Perform the copy operation using the install_dir variable
    cp -Rva --no-preserve=ownership ./usr/local/diamond "$install_dir"
    cd ${workdir}
    rm -R ${workdir}/diamond

    # Install the enryption pack
    mkdir ${workdir}/diamond
    
    mv encryption_pack.rpm diamond
    cd ${workdir}/diamond
    rpm2cpio *.rpm | cpio -idmv
    export RPM_INSTALL_PREFIX="$(pwd)/usr/local"
    cp -p -f ${RPM_INSTALL_PREFIX}/diamond/${lattice_version}/encryption_security/bin/lin64/* ${install_dir}/diamond/${lattice_version}/bin/lin64
    cp -p -f ${RPM_INSTALL_PREFIX}/diamond/${lattice_version}/encryption_security/ispfpga/ep5c00/bin/lin64/libe5cbs.so ${install_dir}/diamond/${lattice_version}/ispfpga/ep5c00/bin/lin64
    cp -p -f ${RPM_INSTALL_PREFIX}/diamond/${lattice_version}/encryption_security/ispfpga/mg5a00/bin/lin64/libm5abs.so ${install_dir}/diamond/${lattice_version}/ispfpga/mg5a00/bin/lin64
    cp -r -p -f ${RPM_INSTALL_PREFIX}/diamond/${lattice_version}/encryption_security/ispfpga/ep5a00s ${install_dir}/diamond/${lattice_version}/ispfpga
    cp -r -p -f ${RPM_INSTALL_PREFIX}/diamond/${lattice_version}/encryption_security/ispfpga/ep5m00s ${install_dir}/diamond/${lattice_version}/ispfpga
    cd ${workdir}
    rm -R ${workdir}/diamond

    # Install LMS
    # Define the content of the .desktop file, using install_dir for the Exec path
    lms_desktop_file_content="[Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Name=LatticeMico System
    GenericName=Launch Lattice Mico System
    Type=Application
    Exec=$install_dir/diamond/$lattice_version/micosystem/LatticeMicoLauncher
    Icon=$install_dir/diamond/$lattice_version/docs/webhelp/eng/connect/Lattice_Icon.ico
    Categories=Electronics;
    "
    /home/z004kw1n/tools/lscc/latticemicosystem/3.13/lm/micosystem/LatticeMicoLauncher
    mkdir ${workdir}/diamond 
    
    mv lms.rpm ${workdir}/diamond
    cd ${workdir}/diamond
    rpm2cpio *.rpm | cpio -idmv
    export RPM_INSTALL_PREFIX="$(pwd)/usr/local"
    /bin/sed -e "s?Root=.*?Root=${install_dir}/latticemicosystem/${lattice_version}?" ${RPM_INSTALL_PREFIX}/latticemicosystem/${lattice_version}/lm/micosystem/mico32system.ini > ${RPM_INSTALL_PREFIX}/latticemicosystem/${lattice_version}/lm/micosystem/latticemicosystem.ini
    rm -f ${RPM_INSTALL_PREFIX}/latticemicosystem/${lattice_version}/micosystem/mico32system.ini
    chmod -f 755 ${RPM_INSTALL_PREFIX}/latticemicosystem/${lattice_version}/micosystem/latticemicosystem.ini
    cp -p -f -r ${RPM_INSTALL_PREFIX}/latticemicosystem/${lattice_version}/lm/* ${install_dir}/diamond/${lattice_version}
    cd ..
    rm -R ${workdir}/diamond

    # Echo the content to the .desktop file
    echo "$desktop_file_content" > "$desktop_file"
    echo "$lms_desktop_file_content" > "$lms_desktop_file"
    # Make the .desktop file executable (optional but recommended)
    chmod +x "$desktop_file"
    chmod +x "$lms_desktop_file"
    echo "export PATH=\"$install_dir/diamond/$lattice_version/bin/lin64:\$PATH\"" | tee -a ~/.bashrc
    echo "export PATH=\"$install_dir/diamond/$lattice_version/micosystem:\$PATH\"" | tee -a ~/.bashrc

    echo '#Lattice' | $SUDO tee  "$usb_programmer_rules_file"
    echo 'SUBSYSTEM=="usb",TAG="HW-USBN2A",ACTION=="add",ATTRS{idVendor}=="1134",ATTRS{idProduct}=="8001",MODE="0660",GROUP="plugdev",SYMLINK+="lattice-%n"' | $SUDO tee -a "$usb_programmer_rules_file"
    echo '#FTDI'    | $SUDO tee -a "$usb_programmer_rules_file"
    echo 'SUBSYSTEM=="usb",TAG="HW-USBN2A",ACTION=="add",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",MODE="0666",GROUP="plugdev",SYMLINK+="ftdi-%n"' | $SUDO tee -a "$usb_programmer_rules_file"
    echo 'SUBSYSTEM=="usb",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",RUN+="/bin/sh -c"basename %p > /sys/bus/usb/drivers/ftdi_sio/unbind""' | $SUDO tee -a "$usb_programmer_rules_file"
    echo 'SUBSYSTEM=="usb",ACTION=="add",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",MODE=="0666",GROUP="plugdev",SYMLINK+="ftdi-%n"'| $SUDO tee -a "$usb_programmer_rules_file"

    #in 2404 it seems some libs are not provided by the os anymore but not correctly "linked" by pnmain
    ln -s $install_dir/diamond/${lattice_version}/bin/lin64/libpng12.so.0.1.2.7 $install_dir/diamond/${lattice_version}/bin/lin64/libpng12.so.0
    ln -s $install_dir/diamond/${lattice_version}/bin/lin64/libQtXml.so.4.8.6 $install_dir/diamond/${lattice_version}/bin/lin64/libQtXml.so.4
    ln -s $install_dir/diamond/${lattice_version}/bin/lin64/libbasngitem.so.1.0.0 $install_dir/diamond/${lattice_version}/bin/lin64/libbasngitem.so.1
    ln -s $install_dir/diamond/${lattice_version}/bin/lin64/libQtGui.so.4.8.6 $install_dir/diamond/${lattice_version}/bin/lin64/libQtGui.so.4
    ln -s $install_dir/diamond/${lattice_version}/bin/lin64/libQtCore.so.4.8.6 $install_dir/diamond/${lattice_version}/bin/lin64/libQtCore.so.4
    # fix the broken libstdc++
    rm $install_dir/diamond/${lattice_version}/synpbase/linux_a_64/lib/libstdc++.so.6
    libpath=$($SUDO find /usr/ -name "libstdc++.so.6" | head -n 1)
    $SUDO cp $libpath $install_dir/diamond/${lattice_version}/synpbase/linux_a_64/lib/libstdc++.so.6
    #Modify diamond to use its own bundled libs:
    sed -i "\$i export LD_LIBRARY_PATH=\"${install_dir}/diamond/${lattice_version}/bin/lin64:\${LD_LIBRARY_PATH}\"" "${install_dir}/diamond/${lattice_version}/bin/lin64/diamond"
    sed -i "\$i export LD_LIBRARY_PATH=\"${install_dir}/diamond/${lattice_version}/bin/lin64:\${LD_LIBRARY_PATH}\"" "${install_dir}/diamond/${lattice_version}/bin/lin64/diamondc"
    sed -i "\$i export LD_LIBRARY_PATH=\"${install_dir}/diamond/${lattice_version}/ispfpga/bin/lin64:\${LD_LIBRARY_PATH}\"" "${install_dir}/diamond/${lattice_version}/bin/lin64/diamond"
    sed -i "\$i export LD_LIBRARY_PATH=\"${install_dir}/diamond/${lattice_version}/ispfpga/bin/lin64:\${LD_LIBRARY_PATH}\"" "${install_dir}/diamond/${lattice_version}/bin/lin64/diamondc"
    sed -i "\$i export LD_LIBRARY_PATH=\"${install_dir}/diamond/${lattice_version}/synpbase/linux_a_64/lib:\${LD_LIBRARY_PATH}\"" "${install_dir}/diamond/${lattice_version}/bin/lin64/diamond"
    sed -i "\$i export LD_LIBRARY_PATH=\"${install_dir}/diamond/${lattice_version}/synpbase/linux_a_64/lib:\${LD_LIBRARY_PATH}\"" "${install_dir}/diamond/${lattice_version}/bin/lin64/diamondc"

    #Add the license:
    cp $node_lock_license_file $install_dir/diamond/${lattice_version}/license/license.dat
    cd $current_dir
    rm -r $workdir

    # Create the synplify wrapper file
    synp_file_content="#! /bin/bash
    export LD_LIBRARY_PATH="$install_dir/diamond/$lattice_version/bin/lin64:${LD_LIBRARY_PATH}"
    $install_dir/diamond/$lattice_version/bin/lin64/synpwrap -gui
    "
    echo "$synp_file_content" > "$synplify_pro_wrapper"
    chmod +x $synplify_pro_wrapper
    #Create a Application shortcut
    synp_desktop_file_content="[Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Name=LatticeMico System
    GenericName=Launch Lattice Mico System
    Type=Application
    Exec=$install_dir/diamond/$lattice_version/bin/lin64/synpwrap
    Icon=$install_dir/diamond/$lattice_version/bin/lin64/synplify.ico
    Categories=Electronics;
    "
    echo "$synp_desktop_file_content" > "$synp_desktop_file"
}
