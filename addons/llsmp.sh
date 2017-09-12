#!/bin/bash

usage(){
    
    echo "USAGE :                $0 [optins] [optins]"
    echo "OPTIONS                                    "
    echo "--install(-i)   [ioCube|redis|memcached|ftp...]  To install some feature componets."
    echo "--uninstall(-r) [all|php|mysql|litespeed]        To uninstall llsmp componets or remove it all."
    echo "vhost           [add|del]                        To add/remove vhost."
    echo "lsws            [start|restart|stop]             To manage litespeed."
    echo "mysql           [start|stop|restart]             To manage mysql."
    echo "pureftpd        [start|stop|restart]             To manage ftp."

}
#================component=================

lsws(){
        :
}

vhost(){
    host_path="/home/www/"
    domain_conf="$host_path/$"
    if [[ ! -d $host_path ]];then
        mkdir -p $host_path
    fi

    local ACTION=$1
    if [[ "x$ACTION" == "xadd" ]];then
        printf "Please input your domain name:"
        read domain
        domain_conf="$host_path/$domain/"
        if [[ -d $domain_conf  ]];then
                echo "The domain $domain  already exist"
                exit
        else 
            mkdir -p $domain_conf
        fi    
    fi
}

mysql(){
:

}

ftp(){
:
}

memcached(){
:

}

redis(){
:
}

usage
