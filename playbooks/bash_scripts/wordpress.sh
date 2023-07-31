#!/bin/bash
#
# SYNOPSIS
#    Configuration of Nginx web server
#
# DESCRIPTION
#    This script will setup nginx, mariadb, php fpm and wordpress cms on it.
#
# VERSION
#       1.0 - Initial version
#       
# CODE
## instalation / configuration

read -p "Username: " user
read -p "Site name: " site_name
read -p "Database password: " db_pass
groupadd $user
useradd -g $user $user

# mysql
mysql -u root --execute="CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -u root --execute="GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -u root --execute="FLUSH PRIVILEGES;"


# SSL certificate
mkdir /etc/ssl/$site_name
cd /etc/ssl/$site_name
openssl req -x509 -sha256 -nodes -days 356 -newkey rsa:2048 -subj "/CN=$site_name/C=PL/L=City" -keyout $site_name.key -out $site_name.crt 

# nginx
rm /etc/nginx/sites-enabled/default
echo "server {
    listen 80;
    server_name www.$site_name $site_name;

    return 301 https://$site_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name www.$site_name;

    ssl_certificate /etc/ssl/$site_name/$site_name.crt;
    ssl_certificate_key /etc/ssl/$site_name/$site_name.key;

    return 301 https://$site_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $site_name;

    root /var/www/html/$site_name;
    index index.php;

    # SSL parameters
    ssl_certificate /etc/ssl/$site_name/$site_name.crt;
    ssl_certificate_key /etc/ssl/$site_name/$site_name.key;

    # log files
    access_log /var/log/nginx/$site_name.access.log;
    error_log /var/log/nginx/$site_name.error.log;

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires max;
        log_not_found off;
    }

}" > /etc/nginx/sites-enabled/$site_name

# wordpress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
mv /var/www/html/wordpress /var/www/html/$site_name
mv /var/www/html/$site_name/wp-config-sample.php /var/www/html/$site_name/wp-config.php
chown -R $user:$user /var/www/html/$site_name
rm /var/www/html/latest.tar.gz
sed -i "s~'DB_NAME', 'database_name_here'~'DB_NAME', 'wordpress'~" /var/www/html/$site_name/wp-config.php
sed -i "s~'DB_USER', 'username_here'~'DB_USER', 'wordpressuser'~" /var/www/html/$site_name/wp-config.php
sed -i "s~'DB_PASSWORD', 'password_here'~'DB_PASSWORD', '$db_pass'~" /var/www/html/$site_name/wp-config.php
sed -i "s~'DB_COLLATE', ''~'DB_COLLATE', 'utf8_unicode_ci'~" /var/www/html/$site_name/wp-config.php

rm /etc/apt/sources.list.d/php.list
systemctl restart php8.2-fpm
systemctl restart nginx