#!/usr/bin/env bash

CONF_DIR="/etc/NetworkManager/conf.d"
CONF_DIR="90-wifi-mac-addr.conf"
CONF_D_PATH="$CONF_DIR/$CONF_DIR"

if [ ! -d "$CONF_DIR" ]; then
    echo "conf dir not exists"
    exit 1
fi

cat << EOF > "$CONF_D_PATH"
[connection-90-wifi-mac-addr-conf]
wifi.cloned-mac-address=permanent
EOF

chmod 644 "$CONF_D_PATH"

systemctl restart NetworkManager
