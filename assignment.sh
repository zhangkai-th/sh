#!/bin/bash

#description: zuoye
#author:zhang
. /etc/os-release


trap "exit" INT 

color(){
	if [[ "$1" == "error" ]]
	then

		printf "\e[1;31m[Error] $(date +"%F %T"): $2\n\e[0m"
	elif [[ "$1" == "info" ]]
	then
		printf "\e[1;32m[info] $(date +"%F %T"): $2\n\e[0m"
	elif [[ "$1" == "warning" ]]
	then
		printf "\e[1;33m[warning] $(date +"%F %T"): $2\n\e[0m"

	fi
}

_functions(){
	color info "start get ip ...."
	my_ip=$(ip a|sed -n -E  's/inet +([0-9]+\.[0-9]+\.[0-9]\.[0-9]+).*/\1/p'|grep -v '127.0.0.1')
	color info "Your ip address:$my_ip"
    	[ $? -eq 0 ] || color error "Not support your os!"
    	color info "judge ip is or not contain 3 ...."
    	echo my_ip|grep 3 &>/dev/null 
    	[ $? -eq 0 ] && date +'%F %T' &>/dev/null || { color warning "your os ip not contain 3,start create user.";groupadd magedu &> /dev/null;for i  in {0..100} ;do  if [ $i -lt 10  ] ;then \
		{ useradd magedu_0$i -G  magedu; } &  \
    else
	    { useradd magedu_$i -G magedu ;} &  
	      \
    fi \
    done;}
	    wait
	    color info "show can login users"
	 awk -F":" 'BEGIN{printf("========================\n");printf("NAME\t|\tsh\n");printf("========================\n")}{if ($7 != "/usr/sbin/nologin" && $7 != "/sbin/nologin"){printf("|%-10s| %10s|\n",$1,$7);printf("------------------------\n")}}' /etc/passwd
}


_install_nginx(){
	REPLY=y
	color warning "reinstall will uninstall and install again,deep think about...."
	[[ -f "/lib/systemd/system/nginx.service" ]] && read -p "your already installed nginx,do you want install again[y|n]?"
	case $REPLY in
		y|Y)
			if [[ "$ID" == "ubuntu" ]] 
			then
				color info "uninstall nginx"
				sudo apt autoremove nginx -y
				color info "install nginx"
				#ubuntu
				sudo apt update -y
				curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
		    		| sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
				echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
				http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
		    		| sudo tee /etc/apt/sources.list.d/nginx.list
				sudo apt update
				sudo apt install nginx -y
				systemctl restart nginx
				systemctl status nginx
				curl -I  127.0.0.1:80|grep "HTTP/1.1 200 OK" &>/dev/null
				color info "nginx server is running ...."
			elif [[ "$ID" == "rocky" ]]
			then
				color info "uninstall nginx"
				yum install yum-utils expect -y
				yum autoremove nginx -y
				color info "install nginx"
				[ -f "/etc/yum.repos.d/nginx.repo" ] && mv /etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo.bak.$(date +%s) &>/dev/null
				cat >/etc/yum.repos.d/nginx.repo<<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/8/x86_64/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
				#yum-config-manager --enable nginx-mainline
				yum install nginx -y
				systemctl restart nginx
				expect <<EOF 
				spawn systemctl status nginx
				expect {
					"(END)" {send "q";exp_continue}
				}
				
EOF

			        curl -I  127.0.0.1:80|grep "HTTP/1.1 200 OK" &>/dev/null
		                color info "nginx server is running ...."
			fi
	;;	
n|N)
	exit 0
	;;
*)
	echo "input error,exit after 2 second"
	sleep 2
	exit 1
esac
}



printf "\e[1;5;31m\tFBI Warning\n
使用脚本之前请确保yum 源配置正确\n\e[0m"
cat <<EOF
1、查询类
2、安装nginx
EOF

read -p "请输入您的选择："
case $REPLY in 
	1)
		_functions
		;;
	2)
		_install_nginx
		;;
	*)
		color error "输入错误，程序退出"
		exit
		;;
esac
