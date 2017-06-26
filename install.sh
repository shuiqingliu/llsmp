#!/bin/bash

#TODO add llsmp information

#Github 
#https://github.com/shuiqingliu/llsmp

#To define the variables in this section
variables(){
	#base info
	software_name="LLsmp"
	software_version="1.0 aphla"
}

#Display the help
usage(){
	echo "$software_name v$software_version"
	echo "Usage: $0 command [option]"
	echo ""
	echo "Commands:"
	echo "  -i  [llsmp|lamp|lnmp|...] to install some software with this   "
	echo "                            command eg install.sh -i ionCube     "

}

#check the os
check_os(){
	case `uname -s` in
	Darwin) OS="darwin";;
	Linux)  OS="linux";;
	*)   error "unkown os : $(uname -m)"
	esac
}

#echo error message and quit the script
error(){
	msg=$1
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Error: $msg" 1>&2
	exit 1
}

