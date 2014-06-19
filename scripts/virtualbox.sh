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
vbga=$( cat /root/.vbox_version )
iso="/root/VBoxGuestAdditions_${vbga}.iso"

mkdir -p /mnt
mount -o loop ${iso} /mnt

## gotta patch the fucking additions for rhel7. only applies to rhel7 but should
## not hurt centos6.
## https://www.google.com/search?client=safari&rls=en&q=error:+%E2%80%98struct+mm_struct%E2%80%99+has+no+member+named+%E2%80%98numa_next_reset%E2%80%99&ie=UTF-8&oe=UTF-8
## http://www.0xf8.org/2014/02/patching-virtualbox-guest-additions-for-sles12rhel7-guests/
## https://www.virtualbox.org/ticket/12638
tmpdir=$(mktemp -d)
pushd ${tmpdir}

/mnt/VBoxLinuxAdditions.run --noexec --keep
pushd install
mkdir unpack
pushd unpack
tar -xjf ../VBoxGuestAdditions-amd64.tar.bz2
pushd src/vboxguest-${vbga}/vboxguest
curl -L https://www.virtualbox.org/raw-attachment/ticket/12638/VBox-numa_no_reset.diff | patch -p3
popd
tar -cjf ../VBoxGuestAdditions-amd64.tar.bz2 .
popd

## typical Oracle bullshit installer.  It tries to install the X11 support no
## matter what.  Even after shaving the yak to hack the installer to *not* do
## that, I still couldn't get it to exit with 0, so fuck it, just ignore the
## exit code.
./install.sh || {
    echo "oh, hey, VBoxGuestAdditions failed to install, exited with ${?}."
    echo "fuck you, Oracle."
}

## cleanup
umount /mnt
rm -rf ${iso} ${tmpdir}

