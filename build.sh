#!/bin/bash

set -e -u

function usage() {
    echo "usage: $0 [ami|vbox]"
}

packer_args="-var git_sha=$( git describe --always --dirty )"

if [ $# -gt 0 ]; then
    case "${1}" in
        ami)
            packer_args="${packer_args} -only=ami-builder-001"
            ;;

        vbox)
            packer_args="${packer_args} -only=vbox-builder-001"
            ;;

        *)
            usage
            exit 1
    esac
fi
        
exec packer build ${packer_args} packer.json
