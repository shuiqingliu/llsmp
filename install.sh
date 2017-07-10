#!/bin/bash

#TODO add llsmp information

#Github 
#https://github.com/shuiqingliu/llsmp
#
#To definition the variables in this section
variables(){
    #base info
    software_name="LLsmp"
    software_version="1.0 aphla"
    debug=true
    OS=
    ADMINPASS=
    ROOTPASS=
    DATABASEPASS=
    DATABASENAME=
    USERNAME=
    SERVER_DIR=/usr/local/llsmp
    TEMPPASS=
}

#Display the help
usage(){
    variables
    echo "$software_name v$software_version"
    echo "Usage: $0 command"
    echo ""
    echo "Commands:"
    echo "  llsmp   to install LiteSpeed+MySQL+PHP on Linux"
    echo "  lnmp    to install Nginx+MySQL+PHP on Linux    "
    echo "  lamp    to install Apache+MySQL+PHP on Linux   "

}

#check the os
check_os(){
    if [[ -f /etc/redhat-release ]] ; then
        ostemp=`cat /etc/redhat-release | awk '{print $1}' | tr [A-Z] [a-z]`
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
    fi
}

# output debug message
debug(){
    info=$1
    if [[ debug==true  ]]; then
        echo "$info" 1>&2
    fi
}

#echo error message and quit the script
error(){
    source ./addons/rainbow.sh  
    echo "*****************************************************"
    while [[ "$1" != "" ]]; do
        echored  "$1" 1>&2
        shift
    done
    echo "*****************************************************"
    exit 1
}

#check user
check_user(){
    if [[ $EUID -ne 0 ]]; then
        error "ERROR: You must be a root user to run this script" "use command like \"sudo -i\" and then input your password"
    fi
}

#generate password
generate_pass(){
    variables
    TEMPPASS=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`    
}
# start istall 
llsmp_install(){
    check_os
    variables
    if [[ OS=="debian" ]];then
        debian_litespeed
        debian_php
        debian_database
    elif [[ OS=="ubuntu" ]]; then
        ubuntu_litespeed
        ubuntu_php
        ubuntu_database
    elif [[ OS=="centos" ]];then
        centos_litespeed
        centos_php
        centos_database
    fi
}
#TODO ADD lnmp,lamp install function

# decide what action to do
do_main(){
    #generate password
    generate_pass
    #reload variables
    variables
    #Check for validity argument
    [[ $1 != "llsmp" && $1 != "lamp" && $1 != "lnmp" ]] &&
        usage && exit
        check_user
    [[ $1 == llsmp ]] &&
        llsmp_install
    [[ $1 == lnmp ]] &&
        lnmp_install           
    [[ $1 == lamp ]] &&
        lamp_install
}

do_main "$@"

