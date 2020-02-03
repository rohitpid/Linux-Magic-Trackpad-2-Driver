#!/bin/sh

reload() {
    modprobe -r hid_magicmouse
    insmod /opt/magic-mouse-fix/hid-magicmouse.ko \
           scroll_acceleration=1 \
           scroll_speed=25 \
           middle_click_3finger=1
}

reload &
