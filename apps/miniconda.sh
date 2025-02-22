#!/bin/bash
work_dir="$1"
conda_prefix="$2"
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
