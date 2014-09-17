#!/bin/bash

exec 0<&- # close stdin

set -e -u -x

## set system clock to hardware clock.  I think this might solve the problem I
## saw where the filesystem superblocks were like a day ahead of the real time
## after creating a new VirtualBox image.
date

## doesn't work on EC2
hwclock -s || true

date

rm -rf /tmp/script.sh /tmp/packages
yum -y clean all
