#!/bin/bash

PARAM= 

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
    SERVER_DIR=/usr/local/lsws
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
                printf "Please input your site port(default:80):"
                read port
                cat $SERVER_DIR/conf/httpd_config.conf | grep $port >/dev/null
                if [[ $? != 0 ]];then

                    vhostconf=$SERVER_DIR/conf/vhosts/$domain/vhconf.conf    
                    mkdir -p $domain_conf
                    cat >> $SERVER_DIR/conf/httpd_config.conf <<END
virtualhost $domain {
vhRoot              $domain_conf
configFile          $vhostconf
allowSymbolLink     1
enableScript        1
restrained          0
setUIDMode          2

}

listener $domain {
address                 *:$port
secure                  0
map            $domain   $domain
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
index  {
  useServer               0
  indexFiles              index.php
}

context / {
  type                    NULL
  location                \$VH_ROOT
  allowBrowse             1
  indexFiles              index.php
 
  rewrite  {
    enable                1
    inherit               1
    rules                 <<<END_rules
    rewriteFile           $domain_conf/.htaccess

END_rules

  }
}
END
                     chown -R lsadm:lsadm $SERVER_DIR/conf/

                    else
                        echo "Your input port already in use"
                        exit
                     fi    

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

check_parameter(){
    PARAM=$1
    local MSG=$2
    local PARAMCHAR=`echo $1 | awk '{print substr($0,1,1)}'`
    if [[ "x$PARAMCHAR" = "x" ]];then
            PARAM=
    fi

    if [[ "x$PARAM" = "x" ]];then
            if [[ "x$MSG" != "x" ]];then
                    echo "Error: '$PARAM' is not valid '$PARAM', please check and try again."
                    usage
                    exit 1
            fi
    fi
}

while [[ "$1" != "" ]];do
        case $1 in
            -i | --install )  check_parameter "$2" "install"
                              if [[ "x$PARAM" != "x" ]];then
                                    shift
                              fi
                              case $PARAM in
                                  ioCube | iocube)  install_cube
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
                        * ) usage
                            exit 0
                            ;;
            esac
            shift
    done        
