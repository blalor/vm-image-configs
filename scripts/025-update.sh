#!/bin/bash

exec 0<&- # close stdin

set -e -u -x

## there's a disconnect between pv-grub and regular grub.  pv-grub reads
## /boot/grub/menu.lst, regular grub reads /boot/grub/grub.conf.  the kernel
## package scripts (rpm -q --scripts kernel) implicitly expect /etc/grub.conf to
## be a symlink to /boot/grub/grub.conf.  The target of that symlink gets
## deleted and recreated, which breaks hard links.  I had a problem with a soft
## link for the same reason.  So, basically the kernel package needs to be
## spoon-fed. :-(

if ! rpm -q grub2 ; then
    ## these are hard-linked on the VBox instance; gotta break that first
    rm -f /boot/grub/menu.lst
    cp /boot/grub/grub.conf /boot/grub/menu.lst
    ( cd /etc && ln -sf ../boot/grub/grub.conf )
fi

old_kernel_pkg=$( rpm -q kernel )

## upgrade everything so we're always up to date
yum upgrade -y

if [ $( rpm -q kernel | wc -l ) -gt 1 ]; then
    rpm -e ${old_kernel_pkg}
fi

if rpm -q grub2 ; then
    echo "will probably need to generate grub.conf by hand for pvgrub"
else
    ## fix up the hard link again
    ln -f /boot/grub/grub.conf /boot/grub/menu.lst
fi

reboot
sleep 60
