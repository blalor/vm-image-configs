#!/bin/bash

exec 0<&- # close stdin

set -e -u -x

## this stuff seems like voodoo; is it really required?

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

# Sync to ensure that the delete completes before this moves on.
sync; sync; sync
