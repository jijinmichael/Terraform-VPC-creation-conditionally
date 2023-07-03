#! /bin/bash
yum install httpd php php-mysqlnd -y
systemctl restart httpd php-fpm
systemctl enable httpd php-fpm
cd /var/www/html/
wget -q https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
mv wordpress/* .
chown -R apache:apache /var/www/html/
mv wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpressdb/" wp-config.php
sed -i "s/username_here/wordpressuser/" wp-config.php
sed -i "s/password_here/wordpress-user/" wp-config.php
sed -i "s/localhost/backend.jijinmichael.local/" wp-config.php
