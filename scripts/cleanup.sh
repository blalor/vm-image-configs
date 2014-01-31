#!/bin/bash

set -e
set -u
set -x

rm -rf /tmp/script.sh /tmp/packages

yum -y clean all
