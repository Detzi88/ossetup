#!/bin/bash
work_dir="$1"
custom_install_dir="$2"
quartus_installer="https://downloads.intel.com/akdlm/software/acdsinst/23.1std.1/993/ib_tar/Quartus-lite-23.1std.1.993-linux.tar"
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi
if [ -z "$custom_install_dir" ]; then
    custom_install_dir="$HOME/tools/quartus"
fi
curl -o "$work_dir/quartus.tar" -L $quartus_installer > /dev/null 2>&1 
mkdir "$work_dir/intel"
tar -xvf "$work_dir/quartus.tar" -C "$work_dir/intel"
"$work_dir/intel/components/QuartusLiteSetup-23.1std.1.993-linux.run" --mode unattended \
--installdir $custom_install_dir \
--create_desktop_shortcuts 1 \
--accept_eula 1 
rm -r "$work_dir/intel"
rm "$work_dir/quartus.tar"
# Install the "rules" for the Programmer
quartus_file="/etc/udev/rules.d/51-usbblaster.rules"
echo '# Intel FPGA Download Cable' | sudo tee  "$quartus_file"
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"'    | sudo tee -a "$quartus_file"
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"'    | sudo tee -a "$quartus_file"
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"'    | sudo tee -a "$quartus_file"
echo '# Intel FPGA Download Cable II'    | sudo tee -a "$quartus_file"
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"'    | sudo tee -a "$quartus_file"
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"'    | sudo tee -a "$quartus_file"
