#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 {on|off}"
    exit 1
fi

SW=$1

source /root/shell/scripts/function.sh

VimRC(){
    cp -p $SCRIPTSDIR/vimrc.txt ~/.vimrc
    if grep -qw nu ~/.vimrc; then
        echo "[ OK ] ~/.vimrc 파일 내용 추가"
    else
        echo "[ FAIL ] ~/.vimrc 파일 내용 추가 실패"
    fi
}

case $SW in
    on) VimRC;;
esac