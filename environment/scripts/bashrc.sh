#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

BashRC(){
    cp -p $SCRIPTSDIR/bashrc.txt ~/.bashrc
    if grep -qw vscode ~/.bashrc; then
        echo "[ OK ] ~/.bashrc 파일 내용 추가"
    else
        echo "[ FAIL ] ~/.bashrc 파일 내용 추가 실패"
    fi
}

case $SW in
    on) BashRC;;
esac