#!/bin/bash

set -e
set -u
set -x

if [ ${PACKER_BUILDER_TYPE} != "virtualbox-iso" ]; then
    echo "skipping for builder ${PACKER_BUILDER_TYPE}"
    exit 0
fi

ifcfg_dev="eth0"
if ip link show enp0s3 >/dev/null 2>&1 ; then
    ifcfg_dev="enp0s3"
fi

## fucking VirtualBox's DNS and CentOS don't play nicely together
sed -i -e '1i\
RES_OPTIONS="single-request-reopen"' /etc/sysconfig/network-scripts/ifcfg-enp0s3

## required for centos7
## https://github.com/mitchellh/vagrant/issues/1172#issuecomment-42263664
if [ $( rpm -q --queryformat '%{VERSION}' centos-release ) -eq 7 ]; then
    ## man, I hate heredocs.
    ## escape *all* the things!
    cat > /etc/NetworkManager/dispatcher.d/fix-slow-dns <<EOF
#!/bin/bash

interface=\${1}

[ -f /etc/sysconfig/network-scripts/ifcfg-\${interface} ] && \\
    . /etc/sysconfig/network-scripts/ifcfg-\${interface}

echo "options \${RES_OPTIONS}" >> /etc/resolv.conf
EOF

chmod +x /etc/NetworkManager/dispatcher.d/fix-slow-dns
fi

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

## install guest additions; at least 4.3.14 required
vbox_ver=$( cat /root/.vbox_version )
vbox_comp_ver=$( echo ${vbox_ver} | awk -F. '{ print (($1 * 10000) + ($2 * 100) + $3) }' )

if [ ${vbox_comp_ver} -lt 40314 ]; then
    echo "vbox version too old; have ${vbox_ver}, need >= 4.3.14"
    exit 1
fi

iso="/root/VBoxGuestAdditions_${vbox_ver}.iso"

mkdir -p /mnt
mount -o loop ${iso} /mnt

/mnt/VBoxLinuxAdditions.run || {
    echo "oh, hey, VBoxGuestAdditions failed to install, exited with ${?}."
    echo "fuck you, Oracle."
}

## cleanup
umount /mnt
rm -rf ${iso}

