#!/bin/bash

#centos sql install

centos_sql(){

    check_version    
    if [[ "x$mysql" == "x1" ]]; then
        local ND=    
        if [[ "x$PHPVER" == "x70" || "x$PHPVER" == "x71" ]]; then
            ND=nd
            if [[ "x$OSVER" == "x5" ]]; then
                rpm -Uvh http://repo.mysql.com/mysql-community-release-el5.rpm
            fi
        fi
        
        yum -y $ACTION lsphp$PHPVER-mysql$ND

    elif [[ "x$MariaDB" == "x1" ]]; then
       


    elif [[ "x$sqlite" == "x1" ]]; then

    fi


}
