#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODPROBE_DIR="/etc/modprobe.d"


# Copy Modprobe config file
cp -f ${DIR}${MODPROBE_DIR}/hid-magicmouse.conf ${MODPROBE_DIR}/hid-magicmouse.conf

# Install drive through DKMS
chmod u+x ${DIR}/scripts/install.sh
${DIR}/scripts/install.sh

# Disable eSCO mode in Bluetooth to fix disconnection problems with the mouse
echo 1 | tee /sys/module/bluetooth/parameters/disable_esco
systemctl restart bluetooth
# persist eSCO mode in Bluetooth setting
echo "options bluetooth disable_esco=1" | tee /etc/modprobe.d/bluetooth-tweaks.conf

# Load driver
sudo modprobe -a hid_magicmouse