#!/bin/bash
# Checking lsb_release
if [ ! -x  /usr/bin/lsb_release ]; then
	echo -e "\033[31mThe lsb_release Command Not Found\e[0m"
	echo -e "\033[36mInstalling lsb-release, Please Wait...\e[0m"
	yum update -y
	yum -y install redhat-lsb-core &>> /dev/null
fi
# Make Variables Available For Later Use
# Lots of code left over from easy engine
LOGDIR=/var/log/easywp
INSTALLLOG=/var/log/easywp/install.log
LINUX_DISTRO=$(lsb_release -i |awk '{print $3}')

# Checking Linux Distro Is CentOS
if [ "$LINUX_DISTRO" != "CentOS" ]
then
	echo -e "\033[31mEasy WP (ewp) is made for CentOS 7[0m"
	exit 100
fi
# Capture Errors
OwnError()
{
	echo -e "[ `date` ] \033[31m$@\e[0m" | tee -ai $INSTALLLOG
	exit 101
}
# Pre Checks To Avoid Later Screw Ups
# Checking Logs Directory
if [ ! -d $LOGDIR ]
then
	echo -e "\033[36mCreating Easy WP (ewp) Log Directory, Please Wait...\e[0m"
	mkdir -p $LOGDIR || OwnError "Unable To Create Log Directory $LOGDIR"
fi

# Checking Tee
if [ ! -x  /usr/bin/tee ]
then
	echo -e "\033[31mTee Command Not Found\e[0m"
	echo -e "\033[36mInstalling Tee, Please Wait...\e[0m"
	yum -y install coreutils &>> $INSTALLLOG || OwnError "Unable to install tee"
fi

echo &>> $INSTALLLOG
echo &>> $INSTALLLOG
echo -e "\033[36mEasy WP (ewp) Installation Started [$(date)]\e[0m" | tee -ai $INSTALLLOG


# Checking Ed
if [ ! -x  /bin/ed ]
then
	echo -e "\033[31mEd Command Not Found\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[36mInstalling Ed, Please Wait...\e[0m" | tee -ai $INSTALLLOG
	yum -y install ed &>> $INSTALLLOG || OwnError "Unable to install ed"
fi

# Checking Bc
if [ ! -x  /usr/bin/bc ]
then
	echo -e "\033[31mBc Command Not Found\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[36mInstalling Bc, Please Wait...\e[0m" | tee -ai $INSTALLLOG
	yum -y install bc &>> $INSTALLLOG || OwnError "Unable to install bc"
fi

# Checking Wget
if [ ! -x  /usr/bin/wget ]
then
	echo -e "\033[31mWget Command Not Found\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[36mInstalling Wget, Please Wait...\e[0m" | tee -ai $INSTALLLOG
	yum -y install wget &>> $INSTALLLOG || OwnError "Unable To Install Wget"
fi

# Checking Curl
if [ ! -x  /usr/bin/curl ]
then
	echo -e "\033[31mCurl Command Not Found\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[36mInstalling Curl, Please Wait...\e[0m" | tee -ai $INSTALLLOG
	yum -y install curl &>> $INSTALLLOG || OwnError "Unable To Install Curl"
fi

# Checking Tar
if [ ! -x  /bin/tar ]
then
	echo -e "\033[31mTar Command Not Found\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[36mInstalling Tar, Please Wait...\e[0m" | tee -ai $INSTALLLOG
	yum -y install tar &>> $INSTALLLOG || OwnError "Unable To Install Tar"
fi

# Checking Git
if [ ! -x  /usr/bin/git ]
then
	echo -e "\033[31mGit Command Not Found\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[36mInstalling Git, Please Wait...\e[0m" | tee -ai $INSTALLLOG
	yum -y install git &>> $INSTALLLOG || OwnError "Unable To Install Git"
fi

# Checking Name Servers
if [[ -z $(cat /etc/resolv.conf 2> /dev/null | awk '/^nameserver/ { print $2 }') ]]
then
	echo -e "\033[31mNo Name Servers Detected\e[0m" | tee -ai $INSTALLLOG
	echo -e "\033[31mPlease Configure /etc/resolv.conf\e[0m" | tee -ai $INSTALLLOG
	exit 102
fi
# Pre Checks End
#Lets install some repos and some packages
#Install EPEL
echo -e "\033[36mChecking for EPEL\e[0m"
if [ ! -f  /etc/yum.repos.d/epel.repo ]
then
	echo -e "\033[31mEPEL not found, installing repo...\e[0m" | tee -ai $INSTALLLOG
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &>> $INSTALLLOG
fi
echo -e "\033[36mChecking for REMI\e[0m"
if [ ! -f  /etc/yum.repos.d/remi.repo ]
then
	echo -e "\033[31mREMI not found, installing repo...\e[0m" | tee -ai $INSTALLLOG
	wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm &>> $INSTALLLOG 
        rpm -Uvh remi-release-7.rpm &>> $INSTALLLOG 
fi
echo -e "\033[36mChecking for MYSQL56\e[0m"
if [ ! -f  /etc/yum.repos.d/mysql-community.repo ]
then
	echo -e "\033[31mMYSQL not found, installing repo...\e[0m" | tee -ai $INSTALLLOG
	yum install -y http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm &>> $INSTALLLOG
        yum install -y mysql mysql-server &>> $INSTALLLOG || OwnError "Check log for error"
fi
echo -e "\033[36mChecking for Nginx Repo\e[0m"
if [ ! -f  /etc/yum.repos.d/nginx.repo ]
then
	echo -e "\033[31mNginx Repo not found, installing repo...\e[0m" | tee -ai $INSTALLLOG
	cp nginx.repo /etc/yum.repos.d/nginx.repo &>> $INSTALLLOG || OwnError "Check log for error"
fi
echo -e "\033[36mChecking for PHP7\e[0m"
if [ ! -x  /usr/bin/php ]
then
	echo -e "\033[31mPHP not found, installing...\e[0m" | tee -ai $INSTALLLOG
	yum install -y --enablerepo=remi-php70 php php-apcu php-fpm php-opcache php-cli php-common php-gd php-mbstring php-mcrypt php-pdo php-xml php-mysqlnd python-tools python-pip python-virtualenv mod_ssl dialog  &>> $INSTALLLOG 
fi
echo -e "\033[36mChecking for Nginx\e[0m"
if [ ! -x  /usr/sbin/nginx ]
then
	echo -e "\033[31mNginx not found, installing...\e[0m" | tee -ai $INSTALLLOG
	yum install nginx -y &>> $INSTALLLOG 
fi
echo -e "\033[36mChecking for Redis\e[0m"
if [ ! -x  /usr/bin/redis-server ]
then
	echo -e "\033[31mRedis not found, installing...\e[0m" | tee -ai $INSTALLLOG
	yum install redis -y &>> $INSTALLLOG 
fi
echo -e "\033[36mChecking for wp-cli\e[0m"
if [ ! -x  /usr/local/bin/wp ]
then
	echo -e "\033[31mWpcli not found, installing...\e[0m" | tee -ai $INSTALLLOG
	cp usr/share/easywp/wp /usr/local/bin/wp
        chmod +x /usr/local/bin/wp
fi

echo -e "\033[36mChecking for ewp\e[0m"
if [ ! -x  /usr/local/bin/ewp ]
then
	echo -e "\033[31mewp not found, installing...\e[0m" | tee -ai $INSTALLLOG
	cp usr/local/bin/easywp /usr/local/bin/ewp
        chmod +x /usr/local/bin/ewp
fi
echo -e "\033[31mchecking ewp timestamp...\e[0m"
if [ "/usr/local/ewp" -ot "usr/local/bin/easywp" ]
then
    echo -e "\033[31mTimestamp is older, updating...\e[0m" | tee -ai $INSTALLLOG
    cp usr/local/bin/easywp /usr/local/bin/ewp
    chmod +x /usr/local/bin/ewp
fi

function COMMONNGINX()
{
	# Personal Settings For Nginx
	echo -e "\033[36mUpdating Nginx Configuration Files, Please Wait...\e[0m"

	grep "Easy WP" /etc/nginx/nginx.conf &> /dev/null
	if [ $? -ne 0 ]
	then
                cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
		# Change Nginx Main Section Settings
		sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
		sed -i "/worker_processes/a \worker_rlimit_nofile 20000;" /etc/nginx/nginx.conf

		# Change Nginx Events Section Settings
		sed -i "s/worker_connections.*/worker_connections 1024;/" /etc/nginx/nginx.conf
		#sed -i "s/# multi_accept/multi_accept/" /etc/nginx/nginx.conf

		# Disable Nginx Version Set Custom Headers Proxy And SSL Settings
		#sed -i "s/http {/http {\n\t##\n\t# Easy WP Settings\n\t##\n\n\tserver_tokens off;\n\treset_timedout_connection on;\n\tadd_header X-Powered-By "the www";\n\tadd_header rt-Fastcgi-Cache \$upstream_cache_status;\n\n\t# Limit Request\n\tlimit_req_status 403;\n\tlimit_req_zone \$binary_remote_addr zone=one:10m rate=1r\/s;\n\n\t# Proxy Settings\n\t# set_real_ip_from\tproxy-server-ip;\n\t# real_ip_header\tX-Forwarded-For;\n\n\tfastcgi_read_timeout 300;\n\tclient_max_body_size 100m;\n\n\t# SSL Settings\n\tssl_session_cache shared:SSL:20m;\n\tssl_session_timeout 10m;\n\tssl_prefer_server_ciphers on;\n\tssl_ciphers HIGH:\!aNULL:\!MD5:\!kEDH;\n\n/" /etc/nginx/nginx.conf
                
                sed -i '/main;/i \\n\t##\n\t# Easy WP Settings\n\t##\n\n\tserver_tokens off;\n\treset_timedout_connection on;\n\tadd_header X-Powered-By "the www";\n\tadd_header rt-Fastcgi-Cache \$upstream_cache_status;\n\n\t# Limit Request\n\tlimit_req_status 403;\n\tlimit_req_zone \$binary_remote_addr zone=one:10m rate=1r\/s;\n\n\t# Proxy Settings\n\t# set_real_ip_from\tproxy-server-ip;\n\t# real_ip_header\tX-Forwarded-For;\n\n\tfastcgi_read_timeout 300;\n\tclient_max_body_size 100m;\n\n\t# SSL Settings\n\tssl_session_cache shared:SSL:20m;\n\tssl_session_timeout 10m;\n\tssl_prefer_server_ciphers on;\n\tssl_ciphers HIGH:\!aNULL:\!MD5:\!kEDH;\n\n' /etc/nginx/nginx.conf
                

		# Change Keepalive Timeout Settings
		sed -i "s/keepalive_timeout.*/keepalive_timeout 30;/" /etc/nginx/nginx.conf

		# Enable Gzip
		sed -i "s/# gzip/gzip/" /etc/nginx/nginx.conf
	fi

	# Check Directory Exist
	if [ ! -d /etc/nginx/conf.d ]
	then
		mkdir /etc/nginx/conf.d || OwnError "Unable To Create /etc/nginx/conf.d"
               
	fi
        	
         cp etc/nginx/conf.d/* /etc/nginx/conf.d/

	systemctl restart nginx

}
function COMMONPHP()
{
	# Personal Settings For PHP
	echo -e "\033[36mUpdating PHP Configuration Files, Please Wait...\e[0m"

	# Needed For Custom php Logs
	if [ ! -d /var/log/php/ ]
	then
		mkdir -p /var/log/php/ || OwnError "Unable To Create php Log Directory: /var/log/php/"
	fi

	grep "Easy WP" /etc/php.ini &> /dev/null
	if [ $? -ne 0 ]
	then

		#TIME_ZONE=$(cat /etc/timezone | head -n1 | sed "s'/'\\\/'")

		# Move PHP’s Session Storage To Memcache
		#sed -i "/extension/a \session.save_handler = memcache\nsession.save_path = \"tcp://localhost:11211\"" /etc/php/mods-available/memcache.ini

		# Change PHP Settings
		sed -i "s/\[PHP\]/[PHP]\n; Easy Engine/" /etc/php.ini
		sed -i "s/expose_php.*/expose_php = Off/" /etc/php.ini
		sed -i "s/post_max_size.*/post_max_size = 100M/" /etc/php.ini
		sed -i "s/upload_max_filesize.*/upload_max_filesize = 100M/" /etc/php.ini
		sed -i "s/max_execution_time.*/max_execution_time = 300/" /etc/php.ini
		#sed -i "s/;date.timezone.*/date.timezone = $TIME_ZONE/" /etc/php.ini

		# Change php-FPM Error Logs Location
		sed -i "s'error_log.*'error_log = /var/log/php/fpm.log'" /etc/php-fpm.conf

		# Enable PHP Status & Ping
		sed -i "s/;ping.path/ping.path/" /etc/php-fpm.d/www.conf
		sed -i "s/;pm.status_path/pm.status_path/" /etc/php-fpm.d/www.conf

		# Change PHP Pool Settings MAX Servers & Request Terminate Timeout
		sed -i "s/;pm.max_requests/pm.max_requests/" /etc/php-fpm.d/www.conf
		sed -i "s/pm.max_children = 5/pm.max_children = 100/" /etc/php-fpm.d/www.conf
		sed -i "s/pm.start_servers = 2/pm.start_servers = 20/" /etc/php-fpm.d/www.conf
		sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = 10/" /etc/php-fpm.d/www.conf
		sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 30/" /etc/php-fpm.d/www.conf
		sed -i "s/;request_terminate_timeout.*/request_terminate_timeout = 300/" /etc/php-fpm.d/www.conf
		sed -i "s/pm = dynamic/pm = ondemand/" /etc/php-fpm.d/www.conf || OwnError "Unable To Chnage Process Manager From Dynamic To Ondemand"
		sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf #Change user and group to nginx
		# Change PHP Fastcgi Socket
		sed -i "s'listen = /var/run/php-fpm.sock'listen = 127.0.0.1:9000'" /etc/php-fpm.d/www.conf || OwnError "Unable To Change PHP Fastcgi Socket"
	fi

   systemctl restart php-fpm
}
function COMMONMYSQL()
{
	# Personal Settings For MySQL
	echo -e "\033[36mUpdating MySQL Configuration Files, Please Wait...\e[0m"

	# Decrease MySQL Wait Timeout
	sed -i "/#max_connections/a wait_timeout = 30 \ninteractive_timeout = 60" /etc/my.cnf
        echo -e "\033[36mRunning Mysql Secure Installation...\e[0m"
	mysql_secure_installation

}
#GOT TO HAVE THIS 
restorecon -v /tmp

systemctl enable nginx
systemctl enable mysqld
systemctl enable php-fpm
#start services
systemctl restart nginx
systemctl restart mysqld
systemctl restart php-fpm

#Common mysql stuff
COMMONMYSQL
#Common Nginx configuration
COMMONNGINX
#common php
COMMONPHP
echo -e "\033[36mCopying easywp files to /etc/easywp\e[0m"
if [ ! -d /etc/easywp/ ]
	then
		mkdir -p /etc/easywp/ || OwnError "Unable To Create /etc/nginx/conf.d"
                cp -R etc/* /etc/easywp/
fi
echo -e "\033[36mCopying easywp files to /etc/easywp/nginx\e[0m"
if [ ! -d /etc/easywp/nginx/conf ]
	then
		mkdir -p /etc/easywp/nginx/conf || OwnError "Unable To Create /etc/easywp/nginx/conf"
                cp -R usr/share/easywp/nginx/* /etc/easywp/nginx/conf
fi
echo -e "\033[36mChecking for directory to throw disabled confs in \e[0m"
if [ ! -d /etc/easywp/disabled/ ]
	then
		mkdir -p /etc/easywp/disabled || OwnError "Unable To Create /etc/easywp/disabled"
fi
echo -e "\033[36mCloning letsencrypt to /etc/letsencrypt\e[0m"
if [ ! -d /etc/letsencrypt ]
	then
		mkdir -p /etc/letsencrypt || OwnError "Unable To Create /etc/letsencrypt"
                git clone https://github.com/letsencrypt/letsencrypt /etc/letsencrypt
fi
echo -e "\033[31mEasy WP installed, create your WP site by  using:\e[0m"
echo -e "\033[31mewp site create domain.tld\e[0m"