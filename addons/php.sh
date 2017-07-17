#!/bin/bash

#install php for llsmp
centos_php(){
    #include check action
    source litespeed.sh
    yum -y $ACTION lsphp$PHPVER lsphp$PHPVER-common lsphp$PHPVER-gd
    lsphp$PHPVER-process lsphp$PHPVER-mbstring lsphp$PHPVER-xml
    lsphp$PHPVER-mcrypt lsphp$PHPVER-pdo lsphp$PHPVER-imap

    #add soft link
    ln -sf $SERVER_DIR/lsphp$PHPVER/bin/lsphp
    $SERVER_DIR/fcgi-bin/lsphp5
}
