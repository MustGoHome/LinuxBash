#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

FirewalldOn(){
    SvcStart firewalld
}


FirewallOff(){
    SvcStop firewalld
}


case $SW in
    on)   FirewalldOn;;
    off)  FirewallOff;;
    *)    echo "Usage : $0 {on|off}"; exit 2;;
esac