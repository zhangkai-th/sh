#!/bin/bash


install(){

            echo -e  "\e[1;32m start install  epel\e[0m"
            yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm


	    echo -e "\e[1;32m replaceing \e[0m"
	    sed -i 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
	    sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*


	    echo -e "\e[1;32m installed \e[0m"
}
version=$(sed -n -r 's/.*([0-9]\.[0-9]\.[0-9]{0,}).*/\1/p'  /etc/redhat-release) &> /dev/null

if [[ $? -eq 0 ]]; then
	if [[ ${version%%.*} -eq 8 ]];then
		install 
	else
		 echo -e "\e[1;31m your version is $version ,not support!\e[0m"
	fi
else
	echo -e "\e[1;31mcan not judge version,area you sure you linux version is centos 8\e[0m"
	read -p "please input your choice[y|Y|yes]" answer
	case $answer in 
		y|Y|yes)
			install
			;;
		*)
			echo -e "\e[1;31m input error,exit.please retry!!\e[0m"
			;;
	esac
fi
