#!/bin/sh

FILE=/tmp/magicmouse.lock

reload() {
    # Check is Lock File exists, if not create it and set trap on exit
    if { set -C; 2>/dev/null >$FILE; }; then
        trap "rm -f $FILE" EXIT
    else
        # Lock file exists. exiting.
        exit
    fi

    modprobe -r hid_magicmouse
    sleep 2
    modprobe -a hid-generic hid_magicmouse
    sleep 2
}

reload &
