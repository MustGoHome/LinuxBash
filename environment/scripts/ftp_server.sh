#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

FTPServerOn(){
    PkgInstall vsftpd ftp
    sed -i "s/^root/#root/" /etc/vsftpd/ftpusers
    sed -i "s/^root/#root/" /etc/vsftpd/user_list
    SvcStart vsftpd
}


FTPServerOff(){
    SvcStop vsftpd
}


case $SW in
    on)   FTPServerOn;;
    off)  FTPServerOff;;
    *)    echo "Usage : $0 {on|off}"; exit 2;;
esac