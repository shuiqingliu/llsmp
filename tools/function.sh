#!/bin/bash

OS=

check_os(){
    if [[ -f /etc/redhat-release ]] ; then
        ostemp=`cat /etc/redhat-release | awk '{print $1}' | tr [A-Z] [a-z]`
        local VER_TEMP=`cat /etc/redhat-release | awk '{print $3}'`
        cat /etc/redhat-release | awk '{print $3}' | grep "6.">/dev/null
        if [[ $? == 0 ]];then
                OS_VERSION=6
        else
            cat /etc/redhat-release | awk '{print $3}' | grep "7.">/dev/null
            if [[ $? == 0 ]];then
               OS_VERSION=7
            else
               echored "We are not support your system version $VER_TEMP at present"
               exit
            fi
        fi

        if [[ "x$ostemp"=="xcentos" ]]; then
                OS="centos"
        else
                error "unkown os : $(uname -m)"
                exit
        fi
    elif [[ -f /etc/lsb_release ]]; then
        case `cat /etc/issue | awk '{print $1}' | tr [A-Z] [a-z]` in
            debian)
                OS="debian"
                ;;
            ubuntu)
                OS="ubuntu"
                ;;
            *)
                error "unkown os : $(uname -m)"
                exit
        esac
    else
        echo "We are not support your system,please contact us for the details"
        exit 0
    fi
}
