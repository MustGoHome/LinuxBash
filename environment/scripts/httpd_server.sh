#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

HttpdServerOn(){
    PkgInstall httpd mod_ssl
    echo WEB > /var/www/html/index.html
    SvcStart httpd
}


HttpdServerOff(){
    SvcStop httpd
}


case $SW in
    on)   HttpdServerOn;;
    off)  HttpdServerOff;;
    *)    echo "Usage : $0 {on|off}"; exit 2;;
esac