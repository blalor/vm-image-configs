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

## remove everything under /var/lib/cloud to force cloud-init to re-run
[ -d /var/lib/cloud ] && find /var/lib/cloud -depth -mindepth 1 -maxdepth 1 | xargs rm -vrf

rm -rf /tmp/*
yum -y clean all

# lets make sure /etc/chef/client.pem is well and truly gone
rm -f /etc/chef/client.pem
