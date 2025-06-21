#!/bin/bash

cat << EOF > $ENV
# [Service Setting]
firewalld=off
selinux=off    
telnet_server=on
ftp_server=on
httpd_server=on

# [Environment Setting]
bashrc=on
vimrc=on
ssh_key_deploy.sh   

# [Install Package]
epel=on
pkg=gcc boxes cowsay
EOF


mkdir -p $BASEDIR/scripts
FILES="
firewalld.sh
selinux.sh
telnet_server.sh
ftp_server.sh
httpd_server.sh
bashrc.sh 
vimrc.sh
epel.sh
pkg.sh
desktopicon.sh
ssh_key_deploy.sh
"

for i in $FILES
do
    > $BASEDIR/scripts/$i
    chmod u+x $BASEDIR/scripts/$i
done

tree $BASEDIR/scripts