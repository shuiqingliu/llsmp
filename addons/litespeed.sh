#!/bin/bash

local VERSION

check_version(){
 
    ACTION=    
    rm release >/dev/null 2>&1    
    wget -O release http://open.litespeedtech.com/packages/release
    last_version=`cat release`
    if [[ -d $SERVER_DIR ]]; then

        if [[ $last_version == `cat $SERVER_DIR/VERSION` ]]; then
              echogreen "You already installed the last version of llsmp"
              while true; do
              read -p "Do you wish to reinstall this program[y/n]?" yn
              case $yn in
                  [Yy]* ) ACTION=reinstall; break;;
                  [Nn]* ) exit;;
                  * ) echo "Please answer yes or no.";;
              esac
        else
            #TODO:upgrade
            ACTION=update    
        fi
    else 
        #TODO: intall a new llsmp   
        ACTION=install
    fi

}

centos_litespeed(){
    
    check_verson
    #install hashlib
    yum -y install python-hashlib
    yum -y $ACTION epel-release
    rpm -Uvh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el$OS_VERSION.noarch.rpm 
    yum -y $ACTION openlitespeed

}

