#!/bin/bash

# ANSI 컬러
RED='\033[0;31m'
GRE='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MGA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# NFS : main
# WEB : server1, server2
# LB  : main(RR) -> server1, server2

# SSH 키 배포(main -> server1, server2)
SSHKeyDeploy(){
    PKGInstaller sshpass
    SvcStart sshd

    # SSH 키 생성
    echo -e 'y\n' | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] SSH 키 생성 성공${NC}"
    else
        echo -e "${RED}[ FAIL ] SSH 키 생성 실패{$NC}"
        exit 1
    fi

    # SSH 키 배포
    for host in 20 30
    do
        sshpass -p "soldesk1." ssh-copy-id -o StrictHostKeyChecking=no root@192.168.10.${host} > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ FAIL ] SSH 키 배포 실패{$NC}"
            exit 4
        fi
    done

    echo -e "${GRE}[ OK ] SSH 키 배포 완료${NC}"
}

# 패키지 인스톨러
PKGInstaller(){
    PKGS=$*

    yum -qy install ${PKGS}    > /dev/null 2>&1
    rpm -q ${PKGS}             > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] ${PKGS} 패키지 설치 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] ${PKGS} 패키지 설치 실패${NC}"
        exit 2
    fi
}

# 서비스 기동 함수
SvcStart(){
    SVC=$1

    systemctl enable ${SVC}  > /dev/null 2>&1
    systemctl start ${SVC}   > /dev/null 2>&1
    STATUS=$(systemctl is-active ${SVC})
    if [ ${STATUS} == "active" ]; then
        echo -e "${GRE}[ OK ] ${SVC} 서비스 기동 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] ${SVC} 서비스 기동 실패${NC}"
        exit 3
    fi
}

# NFS 설정
NFSSetting(){
    PKGInstaller nfs-utils
    SvcStart nfs-server
    
    # main NFS 설정
    mkdir -p /www
    echo "/www     192.168.10.0/24(rw,no_root_squash,nohide,subtree_check)" > /etc/exports
    SvcReStart nfs-server

    # server1, server2 NFS 설정
    for host in 20 30
    do
        # 원격 NFS 패키지 설치
        ssh 192.168.10.${host} yum -qy install nfs-utils > /dev/null 2>&1
        ssh 192.168.10.${host} rpm -q nfs-utils > /dev/null 2>&1

        if [ $? -ne 0 ]; then
            echo -e "${RED}[ FAIL ] 192.168.10.${host} 원격 NFS 설치 실패${NC}"
            exit 6
        fi

        echo -e "${GRE}[ OK ] 192.168.10.${host} 원격 NFS 설치 성공${NC}"

        # 원격 NFS 디렉터리 생성 및 기동
        ssh 192.168.10.${host} mkdir -p /www > /dev/null 2>&1
        ssh 192.168.10.${host} systemctl enable --now nfs-server > /dev/null 2>&1
        STATUS=$(ssh 192.168.10.${host} systemctl is-active nfs-server)
        if [ ${STATUS} != "active" ]; then
            echo -e "${RED}[ FAIL ] 192.168.10.${host} 원격 nfs-server 서비스 기동 실패${NC}"
            exit 7
        fi
        
        # 원격 NFS 마운트
        ssh 192.168.10.${host} mount 192.168.10.10:/www /www 2>&1
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ FAIL ] 192.168.10.${host} 원격 NFS 마운트 실패${NC}"
            exit 8
        fi
        ssh 192.168.10.${host} echo "192.168.10.10/www   /www    nfs     defaults    0 0" >> /etc/fstab
        echo -e "${GRE}[ OK ] 192.168.10.${host} 원격 NFS 마운트 완료${NC}"
    done
}

# 서비스 재기동 함수
SvcReStart(){
    SVC=$1

    systemctl restart ${SVC}   > /dev/null 2>&1
    STATUS=$(systemctl is-active ${SVC})
    if [ ${STATUS} == "active" ]; then
        echo -e "${GRE}[ OK ] ${SVC} 서비스 재기동 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] ${SVC} 서비스 재기동 실패${NC}"
        exit 5
    fi
}

# NFS 설정
WebSetting(){
     for host in 20 30
     do
        # server1, server2 httpd 설치
        ssh 192.168.10.$host yum -qy install httpd mod_ssl > /dev/null 2>&1
        ssh 192.168.10.$host rpm -q httpd > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ FAIL ] 192.168.10.${host} 원격 Httpd 설치 실패${NC}"
            exit 6
        fi

        echo -e "${GRE}[ OK ] 192.168.10.${host} 원격 Httpd 설치 성공${NC}"

        # server1, server2 httpd 기동
        ssh 192.168.10.$host systemctl enable --now httpd > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ FAIL ] 192.168.10.${host} 원격 Httpd 기동 실패${NC}"
            exit 7
        fi

        echo -e "${GRE}[ OK ] 192.168.10.${host} 원격 Httpd 기동 성공${NC}"

        # /etc/httpd/conf.d/vhost.conf 설정
        scp ./lb_directory/vhost.txt 192.168.10.${host}:/etc/httpd/conf.d/vhost.conf > /dev/null 2>&1
        ssh 192.168.10.$host systemctl restart httpd > /dev/null 2>&1
        STATUS=$(ssh 192.168.10.$host systemctl is-active httpd)
        if [ ${STATUS} != "active" ]; then
            echo -e "${RED}[ FAIL ] 192.168.10.${host} vhost 설정 실패${NC}"
            exit 8
        fi
        echo -e "${GRE}[ OK ] 192.168.10.${host} vhost 설정 완료${NC}"
     done
}

# HA Proxy
HAProxySetting(){
    PKGInstaller haproxy

    cp ./lb_directory/haproxy.txt /etc/haproxy/haproxy.cfg > /dev/nmull 2>&1
    haproxy -f /etc/haproxy/haproxy.cfg -c > /dev/nmull 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] HAProxy 설정 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] ${PKGS} HAProxy 설정 실패${NC}"
        exit 9
    fi

    SvcReStart haproxy
}

# 배너
cat << EOF
***************************************
* Date    : 2025-06-20                *
* Name    : LB 설정 스크립트          *
* Author  : YGS                       *
***************************************
EOF

# SSH 키 배포
SSHKeyDeploy

# NFS 설정
NFSSetting

# WEB 설정
WebSetting

# HA Proxy 설정
HAProxySetting

