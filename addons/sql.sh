#!/bin/bash

#centos sql install

centos_database(){
    debug "=======================OS_VERSION=$OS_VERSION============="
    debug "=======================SQL INSTALL START ================="
    debug "=======================mysql version=$mysql==============="   
    yum -y install yum-utils
    yum -y install glibc.i686

    if [[ "x$mysql" == "x1" ]]; then
        #download mysql yum repository
        if [[ "$OS_VERSION" == "6" ]]; then
            rpm -Uvh https://repo.mysql.com/mysql57-community-release-el6.rpm
        elif [[ "$OS_VERSION" == "7" ]]; then
            #install and setting repository 
            rpm -Uvh https://repo.mysql.com/mysql57-community-release-el7.rpm
        fi
        if [[ "x$mysql_ver" == "x56" ]];then
             yum-config-manager --disable mysql57-community
             yum-config-manager --enable mysql56-community 
        elif [[ "x$mysql_ver" == "x55" ]];then 
             yum-config-manager --disable mysql57-community
             yum-config-manager --enable mysql55-community 
        fi
        #install mysql 
        yum -y install mysql-community-server
        debug "=========================mysql install finished=========="

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
