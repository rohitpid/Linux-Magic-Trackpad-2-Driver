#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OPT_DIR="/opt/magic-mouse-fix"
UDEV_DIR="/etc/udev/rules.d"
MODPROBE_DIR="/etc/modprobe.d"


# Copy Modprobe config file
cp -f ${DIR}${MODPROBE_DIR}/hid-magicmouse.conf ${MODPROBE_DIR}/hid-magicmouse.conf

# Install drive through DKMS
chmod u+x ${DIR}/scripts/install.sh
${DIR}/scripts/install.sh

# Copy script to load the driver to OPT directory
mkdir -p ${OPT_DIR}
cp -f ${DIR}/scripts/magic-mouse-2-add.sh ${OPT_DIR}/magic-mouse-2-add.sh
chmod +x ${OPT_DIR}/magic-mouse-2-add.sh

# Copy udev rule and reload udev
cp -f ${DIR}${UDEV_DIR}/10-magicmouse.rules ${UDEV_DIR}/10-magicmouse.rules
udevadm control -R

# Disable eSCO mode in Bluetooth to fix disconnection problems with the mouse
echo 1 | tee /sys/module/bluetooth/parameters/disable_esco
systemctl restart bluetooth
# persist eSCO mode in Bluetooth setting
echo "options bluetooth disable_esco=1" | tee /etc/modprobe.d/bluetooth-tweaks.conf