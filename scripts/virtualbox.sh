#!/bin/bash

set -e
set -u
set -x

## fucking VirtualBox's DNS and CentOS don't play nicely together
sed -i -e '1i\
RES_OPTIONS="single-request-reopen"' /etc/sysconfig/network-scripts/ifcfg-enp0s3

service network restart

## cloud-init causes centos6 virtualbox to take ~2m longer to boot; can leave it
## for centos7
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
    patch \
    binutils

## install guest additions
iso="/root/VBoxGuestAdditions_$( cat /root/.vbox_version ).iso"

mkdir -p /mnt
mount -o loop ${iso} /mnt

/mnt/VBoxLinuxAdditions.run || {
    echo "oh, hey, VBoxGuestAdditions failed to install, exited with ${?}."
    echo "fuck you, Oracle."
}

## cleanup
umount /mnt
rm -rf ${iso} ${tmpdir}

