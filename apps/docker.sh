#!/bin/bash
docker_deps=("ca-certificates" "curl")


install_docker(){
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  . ${SCRIPT_DIR}/../functions.sh
  work_dir="$1"
  custom_install_dir="$2"
  if [ -z "$work_dir" ]; then
      work_dir="./work"
  fi

  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
    sudo apt-get remove $pkg; 
  done
  # Add Docker's official GPG key:

  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get -o DPkg::Lock::Timeout=3600 update

  sudo apt install docker-ce -y
  sudo apt install docker-ce-cli -y
  sudo apt install containerd.io -y
  sudo apt install docker-buildx-plugin -y
  sudo apt install docker-compose-plugin -y
  sudo groupadd docker
  sudo usermod -aG docker $USER
}
