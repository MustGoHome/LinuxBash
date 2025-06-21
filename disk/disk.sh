#!/bin/bash

# 디스크 파티셔닝 함수
DiskPartitioning(){
    name=$1
    type=$2
    fs_type=$3
    directory=$4

    # 디스크 초기화
    dd if=/dev/zero of=${name} bs=1M > /dev/null 2>&1

    # 디스크 파티셔닝 진행
    parted ${name} mklabel ${type} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] 디스크 파티셔닝 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] 디스크 파티셔닝 실패${NC}"
        exit 3
    fi

    # 디스크 파일시스템 파티셔닝 진행
    parted ${name} mkpart primary ${fs_type} 1MiB 100% > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] 디스크 파일 시스템 파티셔닝 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] 디스크 파일 시스템 파티셔닝 실패${NC}"
        exit 4
    fi

    MakeFilesystem $name $type $fs_type $directory
}

# 파일 시스템 생성 함수
MakeFilesystem(){
    name=$1
    type=$2
    fs_type=$3
    directory=$4

    # 디스크 파일 시스템 생성 진행
    mkfs.${fs_type} -f ${name}1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] 디스크 파일 시스템 생성 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] 디스크 파일 시스템 생성 실패${NC}"
        exit 5
    fi

    DiskAutoMount $name $type $fs_type $directory
}

# 디스크 마운트 함수
DiskAutoMount(){
    name=$1
    type=$2
    fs_type=$3
    directory=$4

    # UUID 추출
    dev_id=$(blkid -s UUID -o value ${name}1)
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] 디스크 UUID 추출 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] 디스크 UUID 추출 실패${NC}"
        exit 6
    fi

    # /etc/fstab 설정 추가
    echo "UUID=${dev_id} ${directory} ${fs_type} defaults 0 0" >> /etc/fstab

    # 디스크 마운트
    mount -a > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GRE}[ OK ] 디스크 마운트 완료${NC}"
    else
        echo -e "${RED}[ FAIL ] 디스크 마운트 실패${NC}"
        exit 7
    fi
}

# 검증 함수 로드
source ./disk_directory/disk_validation.sh

# 배너
cat << EOF
*************************************************
* Date    : 2025-06-20                          *
* Name    : Disk 설정 스크립트                  *
* Author  : YGS                                 *
*************************************************
EOF

# 파티셔닝 디스크 선택 메시지
echo -en "${MGA}파티셔닝할 디스크를 선택해주세요.(ex./dev/sdb) : ${NC}"
read name

# 파티셔닝 디스크 유효성 검증
NameValidation $name

# 파티셔닝 유형 선택 메시지
echo -en "${MGA}파티셔닝 유형을 선택해주세요.(mbr|gpt) : ${NC}"
read type

# 파티셔닝 유형 유효성 검증
TypeValidation $type

# 파일 시스템 유형 선택 메시지
echo -en "${MGA}파일 시스템 유형을 선택해주세요.(ext4|xfs) : ${NC}"
read fs_type

# 파일 시스템 유형 유효성 검증
FSTypeValidation $fs_type

# 마운트 디렉터리 선택 메시지
echo -en "${MGA}마운트 디렉터리를 선택해주세요.(ex./oracle) : ${NC}"
read directory

# 마운트 디렉터리 유효성 검증
DirectoryValidation $directory

# 디스크 파티셔닝
DiskPartitioning $name $type $fs_type $directory