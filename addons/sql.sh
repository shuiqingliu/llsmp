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
        cat >> /etc/yum.repos.d/MariaDB.repo <<END
# MariaDB 10.2 CentOS repository list - created 2017-07-25 08:18 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos$OSVER-$OSTYPE
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

END
        yum -y install MariaDB-server MariDB-client
    elif [[ "x$sqlite" == "x1" ]]; then

    fi


}
