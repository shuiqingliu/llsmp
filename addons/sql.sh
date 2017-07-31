#!/bin/bash

#centos sql install

centos_sql(){
    
    check_version    
    yum -y install yum-utils
    if [[ "x$mysql" == "x1" ]]; then
        #download mysql yum repository
        wget --no-check-certificate https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

        #install and setting repository 
        rpm -Uvh mysql57-community-release-el7-11.noarch.rpm
        if [[ "x$mysql_ver" == "x56" ]];then
             yum-config-manager --disable mysql57-community
             yum-config-manager --enable mysql56-community 
        elif [[ "x$mysql_ver" == "x55" ]];then 
             yum-config-manager --disable mysql57-community
             yum-config-manager --enable mysql55-community 
        fi
        #install mysql 
        yum -y install mysql-community-server

    elif [[ "x$MariaDB" == "x1" ]]; then
        if  [[ "x$MariaDB_ver" == "x102" ]]; then 
        cat >> /etc/yum.repos.d/MariaDB.repo <<END
# MariaDB 10.2 CentOS repository list - created 2017-07-25 08:18 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos$OSVER-$OSTYPE
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

END
        elif  [[ "x$MariaDB_ver" == "x101" ]]; then 
                
        cat >> /etc/yum.repos.d/MariaDB.repo <<END
# MariaDB 10.1 CentOS repository list - created 2017-07-25 08:18 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos$OSVER-$OSTYPE
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

END

        elif  [[ "x$MariaDB_ver" == "x55" ]]; then 
                
        cat >> /etc/yum.repos.d/MariaDB.repo <<END
# MariaDB 5.5 CentOS repository list - created 2017-07-25 08:18 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/5.5/centos$OSVER-$OSTYPE
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

END
       fi
        yum -y install MariaDB-server MariDB-client
    elif [[ "x$sqlite" == "x1" ]]; then
        yum -y install sqlite
    fi


}
