#!/bin/bash

#install php for llsmp
centos_php(){
    #include check action
    
    current_dir="$(dirname "$0")"
    source ./addons/litespeed.sh
#    check_version
    debug "=====================PHP INSTALL======================"
    debug "===================PHPVER=$PHPVER====================="
    yum -y install lsphp$PHPVER lsphp$PHPVER-common lsphp$PHPVER-gd  lsphp$PHPVER-process lsphp$PHPVER-mbstring lsphp$PHPVER-xml  lsphp$PHPVER-mcrypt lsphp$PHPVER-pdo lsphp$PHPVER-imap lsphp$PHPVER-mysqlnd   lsphp$PHPVER-pdo lsphp$PHPVER-mbstring  lsphp$PHPVER-opcache lsphp$PHPVER-bcmath  lsphp$PHPVER-soap lsphp$PHPVER-json
    #add soft link
    ln -sf $SERVER_DIR/lsphp$PHPVER/bin/lsphp $SERVER_DIR/fcgi-bin/lsphp5
    debug "==================PHP INSTALL FINISHED================"
}

debian_php(){

    #check action 
    if [[ $ACTION == "reinstall" ]]; then
        $ACTION="--reinstall"
    elif [[ $ACTION == "update" ]]; then
        $ACTION="--only-upgrade"
    else
        $ACTION=""
    fi
    #install base package
    apt-get -y install $ACTION lsphp$PHPVER lsphp$PHPVER-imap  
    #install special package with php version 70 or 71
    if [[ "x$PHPVER" != "x70" && "x$PHPVER" != "x71" ]]; then
            apt-get -y install $ACTION lsphp$PHPVER-gd
            lsphp$PHPVER-mcrypt
    else
            apt-get -y install $ACTION lsphp$PHPVER-common
    fi
    
    #creat soft link
    ln -sf $SERVER_DIR/lsphp$PHPVER/bin/lsphp
    $SERVER_DIR/fcgi-bin/lsphp5


}
