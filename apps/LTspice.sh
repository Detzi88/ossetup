#!/bin/bash
work_dir="$1"
custom_install_dir="$2"
install_wine_package https://ltspice.analog.com/software/LTspiceXVII.exe LTspiceXVII
#Configure wine with the specified prefix
#"LogPixels"=dword:000000c0 in user.reg
WINEARCH=win32 WINEPREFIX="$custom_install_dir" winecfg settings dpi=196
