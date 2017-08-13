#!/bin/bash

#TODO add llsmp information

#includ addons file
my_dir="$(dirname "$0")"
source $my_dir/addons/rainbow.sh 
source $my_dir/addons/litespeed.sh
source $my_dir/addons/php.sh
source $my_dir/addons/sql.sh
#Github 

#https://github.com/shuiqingliu/llsmp
#

#SET GLOBLE VARIABLE
#To definition the variables in this section
variables(){
    #base info
    software_name="LLsmp"
    software_version="1.0 aphla"
    debug=true
    ADMINPASS=
    ROOTPASS=
    DATABASEPASS=
    DATABASENAME=
    USERNAME=
    SERVER_DIR=/usr/local/lsws
    PORT=
    TEMPPASS=
    mysql=
    MariaDB=
    sqlite=
    PHPVER=
    OS_VERSION=
    OS_TYPE=`uname -m`
}

change_sshPort(){
    while true; do
    read -p "Please Reset SSH Port(Default:22 Press Enter)" PORT
    if [[ "$PORT" =~ ^[0-9]+$ ]];then
        if [ "$REPLY" -ge 0 -a "$REPLY" -le 65535 ]; then 
            PORT=$PORT
            sed -i  's/^#\s*Port/#&/g' /etc/ssh/sshd_config 
            sed -i  's/^Port/#&/g' /etc/ssh/sshd_config 
            echo "Port $PORT" >> /etc/ssh/sshd_config
            break
        else
           echored "Please input corrent port number[range:0-65535]"
        fi
    elif [[ "x$PORT" == "x" ]];then
        break
    fi
    done
}

confirm_install(){
    
    while true; do
    read -p "Do you want to Install LLsmp ?[y/n]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
    done
}

select_php(){
    cat  << EOF
    Please select a version of the PHP：
    1.    Install php-5.3
    2.    Install php-5.4
    3.    Install php-5.5
    4.    Install php-5.6
    5.    Install php-7.0 
    6.    Install php-7.1
EOF
    while true;do
    read -p "Enter your choice number(Default[4]Press Enter):" php
    case $php in
        1) PHPVER=53
            break;;
        2) PHPVER=54
            break;;
        3) PHPVER=55
            break;;
        4|"") PHPVER=56
            break;;
        5) PHPVER=70
            break;;
        6) PHPVER=71
            break;;
        *) echo "Please input the correct number";;
    esac
    done
}

select_sql(){
    cat  << EOF
Please select a Version of Database Server:
    1.Install MySQL-5.7
    2.Install MySQL-5.6
    3.Install MySQL-5.5,
    4.Install MariaDB-10.2
    5.Install MariaDB-10.1
    6.Install MariaDB-5.5
    7.Install SQLite
    8.Not Install Database
EOF
    while true;do
    read -p "Enter your choice number(Default[3] Press Enter):" sql
    case $sql in
        1) mysql=1
           mysql_ver=57
            break;;
        2) mysql=1
           mysql_ver=56
            break;;
        ""|3) mysql=1
           mysql_ver=55
            break;;
        4) MariaDB=1
           MariaDB_ver=102
            break;;
        5) MariaDB=1
           MariaDB_ver=101
            break;;
        6) MariaDB=1
           MariaDB_ver=55
            break;;
        7) sqlite=1
            break;;
        8) break;;
        *) echo "Please input the correct number";;
    esac
    done
}

#Display the help
usage(){
    variables
    echo "$software_name v$software_version"
    echo "Usage: $0 command"
    echo ""
    echo "Commands:"
    echo "  llsmp   to install LiteSpeed+MySQL+PHP on Linux"
  #  echo "  lnmp    to install Nginx+MySQL+PHP on Linux    "
  #  echo "  lamp    to install Apache+MySQL+PHP on Linux   "

}

#check the os
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
    TEMPPASS=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`    
}

set_mysql_pass(){
    while true; do
    printf  "Please Set the root password of database :" 
    read  DBPASS 
    if [[ "x$DBPASS" == "x" ]];then
        generate_pass
        TEMPPASS=`expr substr "$TEMPPASS" 1 8`
        DATABASEPASS=$TEMPPASS
        break
    elif [[ ${#DBPASS} -ge 8 ]];then
        DATABASEPASS=$DBPASS
        break
    else
        echo "The minimum password length of 8 character"
    fi
    done
}
set_mysql(){
    if [[ "x$mysql" == "x1" || "x$MariaDB" == "x1" ]];then 
          #start mysql  
          service mysqld start
          echo "==================DB:$DATABASEPASS==================="
          mysqladmin -u root password '$DATABASEPASS'
          #set mysql password
    #elif [[ "x$sqlite" == "x1" ]];then
          #start sqlite fi
    fi
    debug "Your database password is \"$DATABASEPASS\"" >> $SERVER_DIR/password
}

set_litespeed_info(){
    
    #set password 
    read -p "Please Set LiteSpeed Administrator password(Default：llsmp.cn):" ADMINPASS
    if [[ "x$ADMINPASS" == "x" ]];then
         ADMINPASS=llsmp.cn
    else
        ADMINPASS=$ADMINPASS
    fi
    #set email
    while true; do
    read -p "Please Set LiteSpeed Administrator Email(Default：admin@localhost.com):" EMAIL
    case $EMAIL in
        "")
               EMAIL=admin@localhost.com
                break;;
        *@* ) 
                EMAIL=$EMAIL
                break;;
        * ) echored "Please intput right email address.";;
    esac
    done
}
set_litespeed(){
    chown -R lsadm:lsadm $SERVER_DIR/conf/
    ENCRYPT_PASS=`"$SERVER_DIR/admin/fcgi-bin/admin_php" -q "$SERVER_DIR/admin/misc/htpasswd.php" $ADMINPASS`
    echo "admin:$ENCRYPT_PASS" > "$SERVER_DIR/admin/conf/htpasswd"
    sed -i -e "s/adminEmails/adminEmails $EMAIL\n#adminEmails/" "$SERVER_DIR/conf/httpd_config.conf"        

    echo "Your litespeed admin　password is $ADMINPASS" > $SERVER_DIR/password
    echo "Your litespeed email is $EMAIL" >> $SERVER_DIR/password
}

#install finish
finish_msg(){

    echo "=================Install Finished==============="
    echo "=   The litespeed address:localhost:8088       ="
    echo "=   The litespeed admin:localhost:7080         ="
    echo "=   Password file $SERVER_DIR/password         ="
    echo "================================================"
}

# start istall 
llsmp_install(){
    variables
    check_os
    select_php
    select_sql
    set_litespeed_info
    set_mysql_pass
    if [[ $OS == "debian" ]];then
       # debian_litespeed
       # debian_php
       # debian_database
       echored "we are not support the debian distribution at present"    
       exit 
    elif [[ $OS == "ubuntu" ]]; then
      #  ubuntu_litespeed
      #  ubuntu_php
      #  ubuntu_database
       echored "we are not support the ubuntu distribution at present"    
       exit 
    elif [[ $OS == "centos" ]];then
        centos_litespeed
        centos_php
        centos_database
        set_litespeed
        set_mysql
    fi
}
#TODO ADD lnmp,lamp install function

# decide what action to do
do_main(){
    #generate password
    generate_pass
    check_user
    #reload variables
    variables
    #Check for validity argument
    [[ $1 != "llsmp" && $1 != "lamp" && $1 != "lnmp" ]] &&
        usage && exit
    [[ $1 == llsmp ]] &&
        confirm_install
        #select php
        llsmp_install
        finish_msg
    [[ $1 == lnmp ]] &&
       # lnmp_install  
       echored "we are not support the lnmp at present"    
       exit
    [[ $1 == lamp ]] &&
        #lamp_install
       echored "we are not support the lamp at present"    
       exit

}

do_main "$@"

