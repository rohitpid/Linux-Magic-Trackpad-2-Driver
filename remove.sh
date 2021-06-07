#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODPROBE_DIR="/etc/modprobe.d"

# Remove drive through DKMS
chmod u+x ${DIR}/scripts/remove.sh
${DIR}/scripts/remove.sh

# Remove loaded driver
modprobe -r hid_magicmouse

# Remove Modprobe configuration file
rm -f ${MODPROBE_DIR}/hid-magicmouse.conf

# Restart Bluetooth
systemctl restart bluetooth
