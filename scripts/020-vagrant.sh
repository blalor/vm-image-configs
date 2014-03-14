#!/bin/bash

exec 0<&- # close stdin

set -e -u -x

# Vagrant specific
date > /etc/vagrant_box_build_time

## common baseline with ec2 instance
[ -d ~ec2-user/.ssh ] || mkdir -p ~ec2-user/.ssh
touch ~ec2-user/.ssh/authorized_keys
chown -R ec2-user:ec2-user ~ec2-user/.ssh
find ~ec2-user/.ssh -type f | xargs chmod 600
find ~ec2-user/.ssh -type d | xargs chmod 700

/usr/sbin/useradd vagrant
echo vagrant | passwd --stdin vagrant
cat > /etc/sudoers.d/vagrant << EOF
Defaults:vagrant !requiretty
vagrant        ALL=(ALL)       NOPASSWD: ALL
EOF

# Installing vagrant keys
VAG_SSH="/home/vagrant/.ssh"

mkdir -pm 700 ${VAG_SSH}

curl -o ${VAG_SSH}/authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'

chmod 0600 ${VAG_SSH}/authorized_keys
chown -R vagrant ${VAG_SSH}
