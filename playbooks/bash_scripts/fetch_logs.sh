#!/bin/bash
#
# SYNOPSIS
#    Script for fetching logs from exim4
#
# DESCRIPTION
#    This script is used on fetch_logs.yml file and its purpose is to fetch some data from exim logs.
#
# VERSION
#       1.0 - Initial version
#       
# CODE
## instalation / configuration

read -p "String for grep: " info
date_for_file_name=$(date "+%m-%d-%y")
mainlog_filename="mainlog_"$date_for_file_name".txt"
rejectlog_filename="rejectlog_"$date_for_file_name".txt"
mkdir /tmp/exim4
grep $info /var/log/exim4/mainlog* | head -n 50 > /tmp/exim4/$mainlog_filename
grep $info /var/log/exim4/rejectlog* | head -n 50 > /tmp/exim4/$rejectlog_filename
