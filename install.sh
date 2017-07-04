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
    echo "  oplmp   to install OpenLiteSpeed+MySQL+PHp on Linux "

}

#check the os
check_os(){
    case `cat /etc/issue | awk '{print $1}'` in
    Debian)
          OS="debian"
          ;;
    Ubuntu)  
          OS="ubuntu"
          ;;
    Centos)
      OS="centos"
      ;;
    *)   
        error "unkown os : $(uname -m)"
    esac
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
    msg=$1
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "Error: $msg" 1>&2
    exit 1
}

# start istall 
start_install(){
    check_os
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

# decide what action to do
do_main(){

    variables
    
    #Check for validity argument
    [[ $1 != "llsmp" && $1 != "lamp" && $1 != "lnmp" ]] &&
        usage
}

do_main

