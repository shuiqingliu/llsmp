#!/bin/bash

PARAM= 
OS=

source ../tools/function.sh
check_os


# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script."
    exit 1
fi

usage(){
    
    echo "USAGE:   $0 [optins] [optins]"
    echo "example: llsmp.sh  vhost add"
    echo "OPTIONS                                    "
    echo "--install(-i)   [ionCube|redis|memcached|ftp...]  To install some feature componets."
    echo "--uninstall(-r) [all|php|mysql|litespeed]        To uninstall llsmp componets or remove it all."
    echo "vhost           [add|del]                        To add/remove vhost."
    echo "lsws            [start|restart|stop]             To manage litespeed."
    echo "mysql           [start|stop|restart]             To manage mysql."
    echo "pureftpd        [start|stop|restart]             To manage ftp."

}
#================component=================

install_ftp(){
   if [[ "$OS" == "centos" ]];then
      source ../tools/vsftpd_centos.sh
   else
      source ../tools/vsftpd_debian.sh
   fi
}

install_cube(){
   :
}

install_redis(){
   if [[ "$OS" == "centos" ]];then
      sudo yum -y install redis
      
   else
      sudo apt-get -y install redis
   fi
}

lsws(){
        :
}

vhost(){
    host_path="/home/wwwroot"
    SERVER_DIR=/usr/local/lsws
    domain_conf=
    if [[ ! -d $host_path ]];then
        mkdir -p $host_path
    fi

    local ACTION=$1
    if [[ "x$ACTION" == "xadd" ]];then
        printf "Please input your domain name:"
        read domain
        domain_conf="$host_path/$domain"
        if [[ -d $domain_conf  ]];then
                echo "The domain $domain  already exist"
                exit
        else 
                # printf "Please input your site port(default:80):"
                # read port
                # if [[ "x$port" == "x" ]];then
                #   port=80
                # fi
                # cat $SERVER_DIR/conf/httpd_config.conf | grep -w "*:$port" >/dev/null
                # if [[ $? != 0 ]];then
            vhostconf=$SERVER_DIR/conf/vhosts/$domain/vhconf.conf    
            mkdir -p $domain_conf
cat >> $SERVER_DIR/conf/httpd_config.conf <<END
virtualhost $domain {
    vhRoot              $domain_conf/
    configFile          $vhostconf
    allowSymbolLink     1
    enableScript        1
    restrained          1
    setUIDMode          0

}

module cache {
    param <<<PARAMFLAG

    enableCache         0
    qsCache             1
    reqCookieCache      1
    respCookieCache     1
    ignoreReqCacheCtrl  1
    ignoreRespCacheCtrl 0
    expireInSeconds     3600
    maxStaleAge         200
    enablePrivateCache  0
    privateExpireInSeconds 3600                      
    checkPrivateCache   1
    checkPublicCache    1
    maxCacheObjSize     10000000

    PARAMFLAG
}
END
            #mkdir for domain
            mkdir -p $SERVER_DIR/conf/vhosts/$domain
cat > $vhostconf << END
docRoot                   \$VH_ROOT/
vhDomain                  $domain
vhAliases                 *.$domain
enableGzip                1
enableIpGeo               1

errorlog  {
  useServer               1
  logLevel                ERROR
}

END
                #change listener
            sed -i "/map                     Example */a map                     $domain , www.$domain" $SERVER_DIR/conf/httpd_config.conf
            echo "<?php phpinfo(); ?>" > $domain_conf/index.php
            chown -R lsadm:lsadm $SERVER_DIR/conf/
                    # else
                    #     echo "Your input port already in use"
                    #     exit
                    #  fi    

        fi 
    elif [[ "x$ACTION" == "xdel" ]]; then
           #statements   
           printf "Please input the domain name that you want to delete:"
           read deldomain
           domain_path="$host_path/$deldomain"
           if [[ -d $domain_path ]]; then
             #statements
                  while true; do
                  read -p "Do you really want to delete the domain of $deldomain ?[y/n]" yn
                  case $yn in
                      [Yy]* ) break;;
                      [Nn]* ) exit;;
                      * ) echo "Please answer yes or no.";;
                  esac
                  done
                  #do delete action
                  #1,delete web folder
                  #2,delete vhosts config
                  #,delete the relevant content in http_conf
                  rm -rf $domain_path
                  rm -rf $SERVER_DIR/conf/vhosts/$deldomain
                  sed -i -e '/virtualhost $deldomain {/,+35 s/^/#/' $SERVER_DIR/conf/httpd_config.conf
                  #restart server
                  $SERVER_DIR/bin/lswsctrl restart

                  echo ""
                  echo "===================================================="
                  echo "=    The domain fo $deldomain has been delete      ="
                  echo "===================================================="
            else
                echo "The domain of $deldomain not exist,please confirm your input."
                exit 0
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

#check the second argument 
check_parameter(){
    PARAM=$1
    local MSG=$2
    #output the first letter of second parameter 
    local PARAMCHAR=`echo $1 | awk '{print substr($0,1,1)}'`
    if [[ "x$PARAMCHAR" = "x" ]];then
            PARAM=
    fi

    #check the second argument is empty or not
    if [[ "x$PARAM" = "x" ]];then
            if [[ "x$MSG" != "x" ]];then
                    echo "Error: the second argument is not correct , please check and try again."
                    usage
                    exit 1
            fi
    fi
}

#if the first argument is empty then echo usage for user
if [[ "$1" == "" ]];then
    printf "Parameter error ,Please check your command\n"
    echo ""
    usage
    exit 0
fi

#repeat check all parameters and then select special action 
while [[ "$1" != "" ]];do
        case $1 in
            -i | --install )  check_parameter "$2" "install"
                              if [[ "x$PARAM" != "x" ]];then
                                    shift
                              fi
                              case $PARAM in
                                  ionCube | ioncube)  install_cube
                                                    ;;
                                  redis )           install_redis
                                                    ;;
                                  memcached )       install_memcached
                                                    ;;
                                  ftp )             install_ftp
                                                    ;;
                                  *)    echo "We don't support the $PARAM install now"
                                        exit 0
                                        ;;
                              esac
                              ;;
             -r | --uninstall ) check_parameter "$2" "remove"
                              if [[ "x$PARAM" != "x" ]];then
                                    shift
                              fi
                              case $PARAM in
                                  all)  rm_all
                                                    ;;
                                  php )  rm_php       
                                                    ;;
                                  mysql ) rm_mysql 
                                                    ;;
                                  litespeed) rm_lsws 
                                                    ;;
                                  *)    echo "Please check your input $PARAM not support now"
                                        exit 0
                                        ;;
                              esac
                              ;;
                        vhost ) check_parameter "$2" "vhost"
                               if [[ "x$PARAM" != "x" ]];then
                                    shift
                               fi
                              case $PARAM in
                                    add ) vhost add
                                          ;;
                                    del ) vhost del
                                          ;;
                                     * ) echo "Please check your input $PARAM "
                                          exit 0
                                          ;;
                              esac
                              ;;
                        lsws ) check_parameter "$2" "lsws"
                               if [[ "x$PARAM" != "x" ]];then
                                    shift
                               fi
                               case $PARAM in
                                    start ) lsws start
                                          ;;
                                    restart ) lsws restart
                                          ;;
                                    stop  )   lsws stop
                                          ;;       
                                     * ) echo "Please check your input $PARAM "
                                          exit 0
                                          ;;
                                esac
                                ;;
                        mysql ) check_parameter "$2" "mysql"
                               if [[ "x$PARAM" != "x" ]];then
                                    shift
                               fi
                               case $PARAM in
                                    start ) mysql start
                                          ;;
                                    restart ) mysql restart
                                          ;;
                                    stop  )   mysql stop
                                          ;;       
                                     * ) echo "Please check your input $PARAM "
                                          exit 0
                                          ;;
                                 esac
                                ;;

                        pureftpd ) check_parameter "$2" "pureftpd"
                               if [[ "x$PARAM" != "x" ]];then
                                    shift
                               fi
                               case $PARAM in
                                    start ) ftp start
                                          ;;
                                    restart ) ftp restart
                                          ;;
                                    stop  )   ftp stop
                                          ;;       
                                     * ) echo "Please check your input $PARAM "
                                          exit 0
                                          ;;
                                 esac
                                ;;
                        * ) printf "Parameter error ,Please check your command\n"
                            echo ""
                            usage
                            exit 0
                            ;;
        esac
        shift
    done        
