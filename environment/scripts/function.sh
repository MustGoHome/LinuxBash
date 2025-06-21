
# Variable Definitions
export BASEDIR=/root/shell
export ENV=$BASEDIR/env.conf
export SCRIPTSDIR=$BASEDIR/scripts

SvcStop(){
    SVC=$1
    systemctl disable $SVC > /dev/null 2>&1
    systemctl stop $SVC > /dev/null 2>&1
    echo "[ OK ] $SVC가 중지"
}

SvcStart(){
    SVC=$1
    systemctl enable $SVC > /dev/null 2>&1
    systemctl start $SVC > /dev/null 2>&1
    SVCSTATUS=$(systemctl is-active $SVC)
    if [ $SVCSTATUS == "active" ]; then
        echo "[ OK ] $SVC 서비스 기동"
    else
        echo "[ FAIL ] $SVC 서비스 기동 실패"
        exit 2
    fi
}

PkgInstall(){
    PKGS=$*
    yum -qy install $PKGS > /dev/null 2>&1
    rpm -q $PKGS > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[ OK ] $PKGS 설치 완료"
    else
        echo "[ FAIL ] $PKGS 설치 실패"
        exit 3
    fi
}