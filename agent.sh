#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root" 
    exit 1
fi

apt-get update && apt-get install -y curl gnupg apt-transport-https lsb-release

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update

if [ $# -eq 0 ]; then
    read -p "Veuillez entrer l'adresse IP du manager : " WAZUH_MANAGER
else
    WAZUH_MANAGER=$1
fi

WAZUH_MANAGER="$WAZUH_MANAGER" apt-get install wazuh-agent

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list
apt-get update

echo "wazuh-agent hold" | dpkg --set-selections
