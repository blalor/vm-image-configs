#!/bin/bash

exec 0<&- # close stdin

set -e -u

## lock the root account so it can't be logged into
/usr/sbin/usermod -L root

## -- alternatively? --
## change the root password to a random string
# tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | passwd --stdin root
