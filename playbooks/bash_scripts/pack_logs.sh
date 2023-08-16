#!/bin/bash
#
# SYNOPSIS
#    Script for packing logs to zip file
#
# DESCRIPTION
#    This script is used on fetch_archived_logs.yml file and its purpose is to fetch data from logs.
#
# VERSION
#       1.0 - Initial version
#       
# CODE
## instalation / configuration

# Current date

current_day=$(date "+%e")
current_month=$(date "+%b")
files=($(ls))

for file in "${files[@]}"; do
    file_month=$(ls -l "$file" | awk '{print $6}')
    file_day=$(ls -l "$file" | awk '{print $7}')
    if 
done

date_for_file_name=$(date "+%m-%d-%y")
mkdir -p /tmp/$HOSTNAME/$date_for_file_name
apt install -y zip
cd /var/log

if dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/nginx.zip nginx/
fi

if dpkg-query -W -f='${Status}' exim4 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/exim4.zip exim4/
fi

if dpkg-query -W -f='${Status}' mariadb-server 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/mysql.zip mysql/
fi

if dpkg-query -W -f='${Status}' php8.1-fpm 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/php8-fpm.zip php8-fpm/
fi

if dpkg-query -W -f='${Status}' pure-ftpd 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/pure-ftpd.zip pure-ftpd/
fi

if dpkg-query -W -f='${Status}' rabbitmq-server 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/rabbitmq.zip rabbitmq/
fi

if dpkg-query -W -f='${Status}' redis-server 2>/dev/null | grep -q "installed"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/redis.zip redis/
fi

if test -e "/opt/solr*"; then
  zip -r /tmp/$HOSTNAME/$date_for_file_name/solr.zip solr/
fi

#zabbix? 
