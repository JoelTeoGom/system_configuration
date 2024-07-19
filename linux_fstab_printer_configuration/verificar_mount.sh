#!/bin/bash

lsmod > before_mount.txt
mount -o loop memtest86-usb.img /mnt
lsmod > after_mount.txt
diff before_mount.txt after_mount.txt

