#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. ${SCRIPT_DIR}/../functions.sh
work_dir="$1"
custom_install_dir="$2"
if [ -z "$work_dir" ]; then
    work_dir="./work"
fi
# Add Docker's official GPG key:
log_and_install ca-certificates 
log_and_install curl --noupdate
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

log_and_install docker-ce 
log_and_install docker-ce-cli 
log_and_install containerd.io 
log_and_install docker-buildx-plugin 
log_and_install docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER