#!/bin/bash

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OPT="/opt/magic-mouse-fix"
UDEV="/etc/udev/rules.d"

# Build drive to be used for the Bluetooth fix
cd ${DIR}/linux/drivers/hid
make clean
make
cd ${DIR}

# Copy `.ko` and script to activate it to OPT directory
mkdir -p ${OPT}
cp -f ${DIR}/linux/drivers/hid/hid-magicmouse.ko ${OPT}/hid-magicmouse.ko
cp -f ${DIR}/scripts/magic-mouse-2-add.sh ${OPT}/magic-mouse-2-add.sh
chmod +x ${OPT}/magic-mouse-2-add.sh

# Copy udev rule and reload udev
cp -f ${DIR}/udev/rules.d/10-magicmouse.rules ${UDEV}/10-magicmouse.rules
udevadm control -R
/etc/init.d/bluetooth restart

# Clean driver build
cd ${DIR}/linux/drivers/hid
make clean
cd ${DIR}