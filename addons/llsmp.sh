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
