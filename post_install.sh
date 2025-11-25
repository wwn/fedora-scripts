#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "must be su"
  exit
fi

install_basics() {
    dnf install -y \
      https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    dnf install -y mc git java-latest-openjdk-devel.x86_64
    
    dnf remove -y transmission xfburn libreoffice*

    dnf autoremove

    rm -rf /home/*/.config/libreoffice
}

install_chrome() {
    dnf install -y fedora-workstation-repositories
    
    dnf config-manager --set-enabled google-chrome

    dnf install -y google-chrome-stable
}

install_vscode() {
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null'

    dnf check-update
    dnf install -y code
}

install_antigravity() {
    tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
    dnf makecache
    dnf -y install antigravity
}

install_onlyoffice() {
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub org.onlyoffice.desktopeditors -y
}

main() {
    # install_basics
    
    # install_chrome
    
    # install_vscode
    
    # install_antigravity
    
    # install_onlyoffice
}

main
