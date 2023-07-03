#! /bin/bash

yum install mariadb105-server -y
systemctl restart mariadb.service
systemctl enable mariadb.service
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'test123';"
mysql -u root -ptest123 -e "CREATE DATABASE wordpressdb;"
mysql -u root -ptest123 -e "CREATE USER 'wordpressuser'@'%' IDENTIFIED BY 'wordpress-user';"
mysql -u root -ptest123 -e "GRANT ALL PRIVILEGES ON wordpressdb.* TO 'wordpressuser'@'%';"
mysql -u root -ptest -e "flush privileges;"
