#!/bin/bash

set -e
set -u
set -x

## fucking VirtualBox's DNS and CentOS don't play nicely together
sed -i -e '1i\
RES_OPTIONS="single-request-reopen"' /etc/sysconfig/network-scripts/ifcfg-eth0

service network restart

## cloud-init causes virtualbox to take ~2m longer to boot
rpm -e cloud-init

## don't do DNS lookups for ssh when logging in
sed -i -e 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

## build deps for vbox guest additions
yum -y install \
    gcc \
    kernel-devel \
    kernel-headers \
    dkms \
    make \
    bzip2 \
    perl \
    binutils

## install guest additions
iso="/root/VBoxGuestAdditions_$( cat /root/.vbox_version ).iso"

## hack to enable OpenGL support to build
## https://community.oracle.com/message/11282251
## https://forums.virtualbox.org/viewtopic.php?f=3&t=58855
## http://wiki.centos.org/HowTos/Virtualization/VirtualBox/CentOSguest
for kern_dir in /usr/src/kernels/* ; do
    ln -s /usr/include/drm/drm{,_{sarea,mode,fourcc}}.h ${kern_dir}/include/drm/
done

## typical Oracle bullshit installer.  It tries to install the X11 support no
## matter what.  Even after shaving the yak to hack the installer to *not* do
## that, I still couldn't get it to exit with 0, so fuck it, just ignore the
## exit code.

mkdir -p /mnt
mount -o loop ${iso} /mnt

/mnt/VBoxLinuxAdditions.run || {
    echo "oh, hey, VBoxGuestAdditions failed to install, exited with ${?}."
    echo "fuck you, Oracle."
}

## cleanup
umount /mnt
rm -rf ${iso}

