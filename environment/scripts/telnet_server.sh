#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

TelnetServerOn(){
    PkgInstall telnet telnet-server
    SvcStart telnet.socket
}


TelnetServerOff(){
    SvcStop telnet.socket
}


case $SW in
    on)   TelnetServerOn;;
    off)  TelnetServerOff;;
    *)    echo "Usage : $0 {on|off}"; exit 2;;
esac