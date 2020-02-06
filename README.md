# Linux Apple Magic Mouse 2 and Magic Trackpad 2 Driver

This repository contains the linux hid-magicmouse driver with Magic Trackpad 2 and Magic Mouse 2 support for Linux 4.18. For older kernels you might have to diff and backport. It also contains 2 fixes to the Magic Mouse 2 regarding Bluetooth random disconnections and this driver not loading on bluetooth reconnection.

This driver is based off of the work of @robotrovsky, @svartalf, @0xABAD and probably others.

The driver is tested in combination with the xf86-libinput and xf86-mtrack driver.

Please help to test this driver and report issues.

## Install Driver with DKMS and the two fixes.

Setup/install with:

```
    sudo apt-get install dkms
    git clone https://github.com/RicardoEPRodrigues/Linux-Magic-Trackpad-2-Driver.git
    cd Linux-Magic-Trackpad-2-Driver
    chmod u+x install.sh
    sudo ./install.sh
```

## Apple Magic Trackpad 2
The driver supports bluetooth and USB for the trackpad. To connect the Trackpad via bluetooth, it must be clicked once after it is turned on, then the Trackpad tries to reconnect to the last paired (and trusted) connection.

## Apple Magic Mouse 2
The drivers supports regular mouse motion and additionally scrolling and mouse middle click. Middle click is a single finger click near the middle portion of the touch surface OR a 3 finger click anywhere on the touch surface if you put the mouse in 3 finger middle click mode (instructions on how to do this are in the installation section. If you like this, please let me know so I can make it the default). Scrolling is a single finger up or down motion anywhere on the touch surface.

## libinput
You can just use the standard xf86-libinput driver and configure it through your Window-Manager-Settings. This driver works very well, but does not support three-finger-drag, but tap-to-drag.

## mTrack
An example configuration for mtrack can be found in:
```
usr/share/X11/xorg.conf.d/90-magictrackpad.conf 
```
This configuration supports tap-to-click, two-finger-scroll and three-finger-drag. Though scrolling is not as smooth as with xf86-libinput. It can be used as starting point for your own configuration. Make sure, that you have xf86-input-mtrack-git installed and it gets loaded. You find more information about the options here: https://github.com/p2rkw/xf86-input-mtrack

## Installation with DKMS

@adam-h made a DKMS which can be used for testing:

Setup/install with:

You will need a 4.18 or above kernel.

```
    sudo apt-get install dkms
    git clone https://github.com/rohitpid/Linux-Magic-Trackpad-2-Driver.git
    cd Linux-Magic-Trackpad-2-Driver/scripts
    chmod u+x install.sh
    sudo ./install.sh
```

If you want test out 3 finger middle click feature (please do)

```
    cd Linux-Magic-Trackpad-2-Driver/linux/drivers/hid
    make clean
    make
    sudo rmmod hid-magicmouse
    sudo insmod ./hid-magicmouse.ko middle_click_3finger=1
```

Remove with:
```
    sudo ./remove.sh
```
Or just use regular `dkms` commands once you've added `./linux/drivers/hid`.

## Troubleshooting
If the driver is not working, please make sure that the correct hid-magicmouse driver gets loaded and try the following steps:

    cd linux/drivers/hid
    make
    sudo rmmod hid_magicmouse
    sudo insmod ./hid-magicmouse.ko
    tail -f ~/.local/share/xorg/Xorg.0.log

Now unplug the trackpad and plug it back in, to see which driver gets loaded.

## Data Layout of bluetooth packets.

```
		/* The data layout for magic mouse 2 is:
		 * 14 bytes of prefix
		 * data[0] is the device report ID
		 * data[1] is the mouse click events. Value of 1 is left, 2 is right.
		 * data[2] (contains lsb) and data[3] (msb) are the x movement
		 *         of the mouse 16bit representation.
		 * data[4] (contains msb) and data[5] (msb) are the y movement
		 *         of the mouse 16bit representation.
		 * data[6] data[13] are unknown so far. Need to decode this still
		 *
		 * data[14] onwards represent touch data on top of the mouse surface
		 *          touchpad. There are 8 bytes per finger. e.g:
		 * data[14]-data[21] will be the first finger detected.
		 * data[22]-data[29] will be finger 2 etc.
		 * these sets of 8 bytes are passed in as tdata to
		 * magicmouse_emit_touch()
		 *
		 * npoints is the number of fingers detected.
		 * size is minimum 14 but could be any multpiple of 14+ii*8 based on
		 * how many fingers are detected. e.g for 1 finger, size=22 for
		 * 2 fingers, size=30 and so on.
		 */

        /* tdata is 8 bytes per finger detected.
		 * tdata[0] (lsb of x) and least sig 4bits of tdata[1] (msb of x)
		 *          are x position of touch on touch surface.
		 * tdata[1] most sig 4bits (lsb of y) and and tdata[2] (msb of y)
		 *          are y position of touch on touch surface.
		 * tdata[1] bits look like [y y y y x x x x]
		 * tdata[3] touch major axis of ellipse of finger detected
		 * tdata[4] touch minor axis of ellipse of finger detected
		 * tdata[5] contains 6bits of size info (lsb) and the two msb of tdata[5]
		 *          are the lsb of id: [id id size size size size size size]
		 * tdata[6] 2 lsb bits of tdata[6] are the msb of id and 6msb of tdata[6]
		 *          are the orientation of the touch. [o o o o o o id id]
		 * tdata[7] 4 msb are state. 4lsb are unknown.
		 *
		 * [ x x x x x x x x ]
		 * [ y y y y x x x x ]
		 * [ y y y y y y y y ]
		 * [touch major      ]
		 * [touch minor      ]
		 * [id id s s s s s s]
		 * [o o o o o o id id]
		 * [s s s s | unknown]
		 */
```



## Fixes

Below is the explanation to 2 fixes performed when running the `install.sh` shown above. The first relates to the disconnection of the mouse over bluetooth and will restart the bluetooth service. The second regards the driver not being loaded when the mouse reconnects with the computer.

### Bluetooth fix

There have been many complaining of repeated and random disconnections of the Magic Mouse 2. One solution to this is to disable `eSCO mode` on the bluetooth service as shown [in this answer](https://askubuntu.com/a/629495/297110). You can disable it like this:

```
echo 1 | sudo tee /sys/module/bluetooth/parameters/disable_esco
sudo /etc/init.d/bluetooth restart
# persist setting
echo "options bluetooth disable_esco=1" | sudo tee /etc/modprobe.d/bluetooth-tweaks.conf
```

### Driver not loading when connecting Magic Mouse 2

[0xABAD](https://github.com/0xABAD/magic-mouse-2) created a fix that loads the driver when it detects the mouse. Here we'll show an updated version that was changed a bit to use the idProduct of the device to identify any Magic Mouse 2.

To begin we need to build the driver and we'll move it to `/opt/magic-mouse-fix/`:

```
cd Link-Magic-Trackpad-2-Driver/linux/drivers/hid
make clean
make
# Create the folder
sudo mkdir -p /opt/magic-mouse-fix/
sudo cp -f hid-magicmouse.ko /opt/magic-mouse-fix/hid-magicmouse.ko
```

With that we'll create a shell script that will load the driver. Let's create it at `/opt/magic-mouse-fix/` and name it `magic-mouse-2-add.sh` (to create and edit it use something like `sudo nano /opt/magic-mouse-fix/magic-mouse-2-add.sh`). This should be the its contents:

```
#!/bin/sh

reload() {
    modprobe -r hid_magicmouse
    insmod /opt/magic-mouse-fix/hid-magicmouse.ko \
           scroll_acceleration=1 \
           scroll_speed=25 \
           middle_click_3finger=1
}

reload &
```

You can also adjust the scroll_speed to a value of your liking (somewhere between 0 to 63). If you wish to disable scroll acceleration or middle clicking with 3 fingers then set those values to zero. Give the script permission to run with `sudo chmod +x /opt/magic-mouse-fix/magic-mouse-2-add.sh`. When this script is run it will unload the default Magic Mouse driver and then load the new one built eariler.

We now need to create a `udev` rule that runs the script and loads the driver when the Mouse connects. In `/etc/udev/rules.d` directory create a `10-magicmouse.rules` file and add the following:

```
SUBSYSTEM=="input", \
    KERNEL=="mouse*", \
    KERNELS=="0005:004C:0269*", \
    ACTION=="add", \
    SYMLINK+="input/magicmouse-%k", \
    RUN+="/opt/magic-mouse-fix/magic-mouse-2-add.sh"
```

The `10-` prefix was picked arbitrarily and could be any number as it is used to determine the lexical ordering of rules in the kernel. The earlier the file is loaded guarantees that the rule will be applied before any others.
 
Now we need to reload the `udev` database with:

```
sudo udevadm control -R
```

With that in place the Magic Mouse 2 will now be properly loaded with scrolling when connected via Bluetooth. Note that isn't perfect and sometimes the kernel will attempt to reload the driver several times and may a few seconds. 

## Thanks
* https://github.com/ponyfleisch/hid-magictrackpad2
* https://github.com/adam-h/Linux-Magic-Trackpad-2-Driver
* https://github.com/bobbysue/Linux-Magic-Trackpad-2-Driver
* https://github.com/svartalf/hid-magicmouse2
