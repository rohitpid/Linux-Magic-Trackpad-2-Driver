#!/bin/bash

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OPT_DIR="/opt/magicmouse-hid"
UDEV_DIR="/etc/udev/rules.d"
MODPROBE_DIR="/etc/modprobe.d"

# Remove drive through DKMS
chmod u+x ${DIR}/scripts/remove.sh
${DIR}/scripts/remove.sh

# Remove Modprobe configuration file
rm -f ${MODPROBE_DIR}/hid-magicmouse.conf

# Copy `.ko` and script to activate it to OPT directory
rm -rf ${OPT_DIR}

# Remove the udev rule and reload udev
rm -f ${UDEV_DIR}/10-magicmouse.rules
udevadm control -R

# Restart Bluetooth
systemctl restart bluetooth
