#!/bin/bash

# ANSI 컬러 팔레트
RED='\033[0;31m'
GRE='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MGA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 전역 변수
domain=""
eth=""
host=""


# 패키지 인스톨러
PKGInstaller(){
    PKGS=$*

    yum -qy install ${PKGS}    > /dev/null 2>&1
    rpm -q ${PKGS}             > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] ${PKGS} 패키지 설치 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] ${PKGS} 패키지 설치 실패${NC}"
        exit 1
    fi

    SvcStart named
}

# 서비스 기동
SvcStart(){
    SVC=$1

    systemctl enable ${SVC}  > /dev/null 2>&1
    systemctl start ${SVC}   > /dev/null 2>&1
    STATUS=$(systemctl is-active ${SVC})
    if [ ${STATUS} == "active" ]; then
        echo -e "${GRE}[ OK ] ${SVC} 서비스 기동 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] ${SVC} 서비스 기동 실패${NC}"
        exit 2
    fi
}

# DNS 설정
DNSConfiguration(){
    domain=$1
    eth=$2

    # /etc/named.conf 설정
    cp -av ./dns_directory/named.txt /etc/named.conf > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] /etc/named.conf 설정 완료${NC}"
    else 
        echo -e "${RED}[ FAIL ] /etc/named.conf 설정 실패${NC}"
        exit 3
    fi

    # /etc/rfc1912.zones 설정
    cp -av ./dns_directory/named.rfc1912.txt /etc/named.rfc1912.zones > /dev/null 2>&1
    sed -i "s/sample/${domain}/g" /etc/named.rfc1912.zones
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] /etc/rfc1912.zones 설정 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] /etc/rfc1912.zones 설정 실패${NC}"
        exit 3
    fi

    ZoneConfiguration $domain $eth
}

# Zone 설정
ZoneConfiguration(){
    domain=$1
    eth=$2

    # /var/named/${domain}.zone 설정
    cp -av ./dns_directory/zone.txt /var/named/${domain}.zone > /dev/null 2>&1
    sed -i "s/sample.com/${domain}/g" "/var/named/${domain}.zone"
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] /var/named/${domain}.zone 설정 완료(1/2)${NC}"
    else
        echo -e "${RED}[ FAIL ] /var/named/${domain}.zone 설정 실패(1/2)${NC}"
        exit 4
    fi

    # /var/named/${domain}.zone 설정
    host=$(nmcli con show ${eth} | grep ipv4.addresses | awk -F: '{print $2}' | tr -d ' ' | cut -d'/' -f1)
    sed -i "s/192.168.10.10/${host}/g" "/var/named/${domain}.zone"
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] /var/named/${domain}.zone 설정 완료(2/2)${NC}"
    else
        echo -e "${RED}[ FAIL ] /var/named/${domain}.zone 설정 실패(2/2)${NC}"
        exit 4
    fi

    HostDNSSetting $domain $eth $host
}

# 호스트 DNS 설정
HostDNSSetting(){
    domain=$1
    eth=$2
    host=$3

    nmcli con modify ${eth} ipv4.dns ${host} +ipv4.dns 8.8.8.8 ipv4.dns-search ${domain}
    nmcli con up ${eth} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] 호스트 DNS 설정 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] 호스트 DNS 설정 실패${NC}"
        exit 5
    fi
}

# 배너
cat << EOF
***************************************
* Date    : 2025-06-20                *
* Name    : DNS 설정 스크립트         *
* Author  : YGS                       *
***************************************
EOF

# DNS 도메인 선택 메시지
echo -en "${MGA}도메인을 지정해주세요. : (ex.example.com) : ${NC}"
read domain

# NIC Connection 선택 메시지
echo -en "${MGA}NIC Connection Name을 입력해주세요. : (ex.eth0) : ${NC}"
read eth

# DNS 패키지 설치
PKGInstaller bind bind-utils

# DNS 설정
DNSConfiguration $domain $eth

