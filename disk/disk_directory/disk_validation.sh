#!/bin/bash

# ANSI 컬러 팔레트
RED='\033[0;31m'
GRE='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MGA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 파티셔닝 디스크 유효성 검증 함수
NameValidation(){
    name=$1

    fdisk -l ${name} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ FAIL ] 유효한 디스크가 아닙니다.${NC}"
        exit 1
    fi
}

# 파티셔닝 유효성 검증 함수
TypeValidation(){
    type=$(echo $1 | tr [A-Z] [a-z])

    if [[ ${type} != "mbr" && ${type} != "gpt" ]]; then
        echo -e "${RED}[ FAIL ] 유효한 파티셔닝 유형 아닙니다.${NC}"
        exit 1
    fi
}
# 파일 시스템 유형 유효성 검증 함수
FSTypeValidation(){
    fs_type=$(echo $1 | tr [A-Z] [a-z])

    if [[ ${fs_type} != "ext4" && ${fs_type} != "xfs" ]]; then
        echo -e "${RED}[ FAIL ] 유효한 파일 시스템이 유형이 아닙니다.${NC}"
        exit 1
    fi
}

# 마운트 디렉터리 유효성 검증 함수
DirectoryValidation(){
    directory=$1
    
    mkdir -p ${directory}
    if [ ! -d ${directory} ]; then
        echo -e "${RED}[ FAIL ] 유효한 디렉터리가 아닙니다.${NC}"
        rmdir ${directory}
        exit 1
    fi
}