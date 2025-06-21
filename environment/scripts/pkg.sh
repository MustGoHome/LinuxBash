#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

PKGS=$*
PKGS=$(echo $PKGS | sed 's/,/ /g')

source /root/shell/scripts/function.sh

PkgInstall $PKGS
