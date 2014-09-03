#!/bin/bash

exec 0<&- # close stdin

set -e -u

if [ ${PACKER_BUILDER_TYPE} != "virtualbox-iso" ]; then
    echo "skipping for builder ${PACKER_BUILDER_TYPE}"
    exit 0
fi

# Vagrant specific
date > /etc/vagrant_box_build_time

/usr/sbin/useradd vagrant
echo vagrant | passwd --stdin vagrant
cat > /etc/sudoers.d/vagrant << EOF
Defaults:vagrant !requiretty
vagrant        ALL=(ALL)       NOPASSWD: ALL
EOF

chmod 440 /etc/sudoers.d/vagrant

# Installing vagrant keys
VAG_SSH="/home/vagrant/.ssh"

mkdir -pm 700 ${VAG_SSH}

curl -f -S -L -o ${VAG_SSH}/authorized_keys 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'

chmod 0600 ${VAG_SSH}/authorized_keys
chown -R vagrant ${VAG_SSH}
