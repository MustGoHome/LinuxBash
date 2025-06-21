#!/bin/bash

set -e

# Variable Definitions
BASEDIR=/root/shell
ENV=$BASEDIR/env.conf
SCRIPTSDIR=$BASEDIR/scripts


# env.conf 파일 체크
[ ! -f $BASEDIR/env.conf ] && exit 1

for line in $(cat $ENV | egrep -v '^$|^#')
do
    FUN=$(echo $line | awk -F= '{print $1}')
    ONOFF=$(echo $line | awk -F= '{print $2}')
    #echo "$FUN : $ONOFF"

    case $FUN in
        firewalld)      $SCRIPTSDIR/$FUN.sh $ONOFF;;
        selinux)        $SCRIPTSDIR/$FUN.sh $ONOFF;;
        telnet_server)  $SCRIPTSDIR/$FUN.sh $ONOFF;;
        ftp_server)     $SCRIPTSDIR/$FUN.sh $ONOFF;;
        httpd_server)   $SCRIPTSDIR/$FUN.sh $ONOFF;;
        bashrc)         $SCRIPTSDIR/$FUN.sh $ONOFF;;
        vimrc)          $SCRIPTSDIR/$FUN.sh $ONOFF;;
        epel)           $SCRIPTSDIR/$FUN.sh $ONOFF;;
        pkg)            $SCRIPTSDIR/$FUN.sh $ONOFF;;
        ssh_key_deploy) $SCRIPTSDIR/$FUN.sh $ONOFF;;          
        *) echo "[ Syntax Error ] env.conf 파일의 문법이 잘못 되었습니다."; exit 2;;
    esac

done
