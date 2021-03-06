#!/bin/bash
echo "Ubuntu installation script for..."
echo "- Nginx"
echo "- Php7.0"
echo "- Mysql-Server"
echo "- Git, Curl, Htop, Vnstat"
read -p "Continue with installation? (y/n)" CONTINUE
if [ $CONTINUE = "y" ]; then
	read -p "Install Nginx? (y/n)" NGINX
	if [ $NGINX = "y" ]; then
		sudo apt-get install -y nginx
		sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
		echo "Moving default site file to /etc/nginx/sites-available/default.backup"
		read -p "Would you like to modify the Nginx site file? (y/n)" MOD
		if [ $MOD = "y" ]; then
			sudo nano /etc/nginx/sites-available/default
		fi
		sudo nginx -t
		sudo systemctl reload nginx
		sudo systemctl restart nginx
	fi	
	read -p "Install PHP7.0? (y/n)" PHP
	if [ $PHP = "y" ]; then
		sudo apt-get install software-properties-common
		sudo add-apt-repository ppa:ondrej/php
		sudo apt install -y php7.0 php7.0-fpm php7.0-cli php7.0-mcrypt php7.0-mbstring php7.0-mysql
		sudo echo 'cgi.fix_pathinfo=0' >> /etc/php/7.0/fpm/php.ini
		echo 'Adding cgi.fix_pathinfo=0 to /etc/php/7.0/fpm/php.ini'
		truncate -s 0 /etc/nginx/sites-available/default
		echo "server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/html;

	# Add index.php to the list if you are using PHP
	index idnex.php index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		try_files $uri $uri/ =404;
	}
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
	}
}" >>  /etc/nginx/sites-available/default
		read -p "Would you like to modify the FPM php.ini file? (y/n)" INI
		if [ $INI = "y" ]; then
			sudo nano /etc/php/7.0/fpm/php.ini
		fi
		sudo systemctl restart php7.0-fpm
	fi
	read -p "Install mysql-server? (y/n)" mysql
	if [ $mysql = "y" ]; then
		sudo apt install -y mysql-server
		sudo mysql_secure_installation
		sudo mysql << EOF
		use mysql;
		ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'mysqlpw';
		flush privileges;
		exit
EOF
	fi
	read -p "Install Curl, Git, Htop, Vnstat? (y/n)" CGC
	if [ $CGC = "y" ]; then
		sudo apt-get install -y curl git htop vnstat
	fi
else
	exit
fi
