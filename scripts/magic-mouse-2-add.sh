#!/bin/sh

FILE=/tmp/magicmouse-driveload

reload() {
    if [ ! -f "$FILE" ]; then
        touch $FILE

        modprobe -r hid_magicmouse
        sleep 2
        modprobe -a hid-generic hid_magicmouse

        sleep 2
        rm -f "$FILE"

    fi
}

reload &
