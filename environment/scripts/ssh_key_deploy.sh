#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

SSHKeyDeploy(){
    PkgInstall sshpass
    SvcStart sshd
    echo -e 'y\n' | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa > /dev/null 2>&1
    
    for i in 10 20
    do
        sshpass -p "soldesk1." ssh-copy-id -o StrictHostKeyChecking=no root@192.168.10.$i >/dev/null 2>&1
        if [ ! $? -eq 0 ]; then
            echo "[ FAIL ] SSH 키 배포 실패"
            exit 2
        fi
    done

    for host in 10 20
    do
        ssh -o StrictHostKeyChecking=no 192.168.10.$host hostname > /dev/null 2>&1
        if [ ! $? -eq 0 ]; then
            echo "[ FAIL ] SSH 접속 테스트 실패"
            exit 3
        fi
    done

    echo "[ OK ] SSH 키 배포 및 접속 설정 완료"
}

source /root/shell/scripts/function.sh

case $SW in
    on) SSHKeyDeploy;;
esac