#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

SelinuxOn(){
    STATUS=$1
    case $STATUS in
        Permissive) setenforce 1
                    sed -i "s/^SELINUX=permissvie/SELINUX=enforcing/" /etc/selinux/config;;
        Disabled)   sed -i "s/^SELINUX=disabled/SELINUX=enforcing/" /etc/selinux/config
                    echo "[ 주의 ] 반드시 재부팅을 해야 합니다.";;
    esac
    echo "[ OK ] $STATUS -> Enforcing 상태로 변경"
}

SelinuxOff(){
    STATUS=$1
    case $STATUS in
        Enforcing)  setenforce 0
                    sed -i "s/^SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config;;
    esac
    echo "[ OK ] $STATUS -> Permissvie or Disabled 상태로 변경"
}

SESTATUS=$(getenforce)

case $SW in
    on)   SelinuxOn $SESTATUS;;
    off)  SelinuxOff $SESTATUS;;
    *)    echo "Usage : $0 {on|off}"; exit 2;;
esac