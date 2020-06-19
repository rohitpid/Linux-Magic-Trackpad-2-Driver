#!/bin/bash

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OPT="/opt/magic-mouse-fix"
UDEV="/etc/udev/rules.d"

# Copy `.ko` and script to activate it to OPT directory
rm -rf ${OPT}

# Remove the udev rule and reload udev
rm ${UDEV}/10-magicmouse.rules
udevadm control -R
/etc/init.d/bluetooth restart
