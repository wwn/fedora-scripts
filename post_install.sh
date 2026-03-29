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
    
    dnf remove -y transmission xfburn claws-mail libreoffice*

    dnf autoremove
    
    rm -rf /home/*/.config/libreoffice
}

install_and_set_JetBrainsMonoNerdFont() {
    local FONT_NAME="JetBrainsMono Nerd Font Mono"
    local FONT_SIZE="11"
    local FULL_FONT="${FONT_NAME} ${FONT_SIZE}"

    dnf install -y jetbrains-mono-fonts-all curl unzip

    FONT_DIR="/usr/share/fonts/JetBrainsMonoNerd"
    mkdir -p "$FONT_DIR"
    curl -L -o /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -q -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm -f /tmp/JetBrainsMono.zip

    fc-cache -fv "$FONT_DIR"

    REAL_USER=${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}

    if [ "$REAL_USER" = "root" ]; then
        echo "wrong user"
        return
    fi

    REAL_USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
    REAL_USER_ID=$(id -u "$REAL_USER")

    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${REAL_USER_ID}/bus"

    if pgrep -u "$REAL_USER_ID" -x "gnome-session|gnome-shell" > /dev/null; then
        echo "configure gnome terminal"
        
        PROFILE=$(sudo -E -u "$REAL_USER" gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \')
        
        if [ -n "$PROFILE" ] && [ "$PROFILE" != "nothing" ]; then
            sudo -E -u "$REAL_USER" gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/" use-system-font false
            sudo -E -u "$REAL_USER" gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/" font "$FULL_FONT"
            echo "font set to $FULL_FONT"
        else
            echo "font not set,; no profile"
        fi

    elif pgrep -u "$REAL_USER_ID" -x "xfce4-session" > /dev/null; then
        echo "configure xfce-terminal"
        TERMINAL_DIR="${REAL_USER_HOME}/.config/xfce4/terminal"
        TERMINAL_RC="${TERMINAL_DIR}/terminalrc"

        sudo -u "$REAL_USER" mkdir -p "$TERMINAL_DIR"

        if [ ! -f "$TERMINAL_RC" ]; then
            sudo -u "$REAL_USER" bash -c "cat <<EOF > '$TERMINAL_RC'
[Configuration]
FontName=$FULL_FONT
FontUseSystem=FALSE
EOF"
        else
            if grep -q "^FontName=" "$TERMINAL_RC"; then
                sed -i "s|^FontName=.*|FontName=$FULL_FONT|" "$TERMINAL_RC"
            else
                echo "FontName=$FULL_FONT" >> "$TERMINAL_RC"
            fi
            
            if grep -q "^FontUseSystem=" "$TERMINAL_RC"; then
                sed -i 's/^FontUseSystem=.*/FontUseSystem=FALSE/' "$TERMINAL_RC"
            else
                echo "FontUseSystem=FALSE" >> "$TERMINAL_RC"
            fi
            
            chown "$REAL_USER":"$REAL_USER" "$TERMINAL_RC"
        fi
        echo "font set to $FULL_FONT"

    else
        echo "no gnome or xfce found for $REAL_USER"
    fi
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
    # install_and_set_JetBrainsMonoNerdFont
    # install_chrome
    # install_vscode
    # install_antigravity
    # install_onlyoffice
}

main
