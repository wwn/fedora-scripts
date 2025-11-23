#!/usr/bin/env bash

CONF_DIR="/etc/NetworkManager/conf.d"
KONF_FILE="90-wifi-mac-addr.conf"
PATH="$CONF_DIR/$KONF_FILE"

if [ ! -d "$CONF_DIR" ]; then
    echo "conf dir not exists"
    exit 1
fi

cat << EOF > "$PATH"
[connection-90-wifi-mac-addr-conf]
wifi.cloned-mac-address=permanent
EOF

chmod 644 "$PATH"

systemctl restart NetworkManager
