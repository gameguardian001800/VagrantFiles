#!/bin/bash
yum update
yum upgrade -y
yum install -y yum-utils nano git wget zip unzip https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php72
yum -y install php php-pdo php-mysqlnd php-opcache php-zip php-xml php-gd php-devel php-mysql php-intl php-mbstring php-bcmath php-json php-iconv php-soap
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum localinstall -y mysql57-community-release-el7-11.noarch.rpm
yum update -y
yum-config-manager --enable mysql57-community
yum install mysql-community-server -y
wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64
wget https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
sudo chmod +x mhsendmail_linux_amd64
sudo chmod +x MailHog_linux_amd64
sudo cp MailHog_linux_amd64 /usr/local/bin/mailhog
sudo cp mhsendmail_linux_amd64 /usr/local/bin/mhsendmail
sudo tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=Mailhog
After=network.target vagrant.mount
[Service]
ExecStart=/usr/local/bin/mailhog \
-api-bind-addr 0.0.0.0:8025 \
-ui-bind-addr 0.0.0.0:8025 \
-smtp-bind-addr 0.0.0.0:1025 > /dev/null 2>&1 &
[Install]
WantedBy=multi-user.target
EOL
sudo service mailhog start  
service mysqld start
sudo chkconfig mailhog on
sudo chkconfig httpd on
sudo chkconfig mysqld on
service httpd restart
sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php.ini 
sudo sed -i 's,sendmail_path = /usr/sbin/sendmail -t -i,sendmail_path = /usr/local/bin/mailhog,g' /etc/php.ini 
sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php.ini 
sudo sed -i 's/max_input_time = 60/max_input_time = 1800/g' /etc/php.ini 
sudo sed -i 's/max_execution_time = 30/max_execution_time = 1800/g' /etc/php.ini 
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux 
DOMAINS=("devlearnground.com")
mkdir /etc/httpd/sites-available
mkdir /etc/httpd/sites-enabled
## Loop through all sites
for ((i=0; i < ${#DOMAINS[@]}; i++)); do
## Current Domain
DOMAIN=${DOMAINS[$i]}
echo "Creating directory for $DOMAIN..."
mkdir -p /var/www/$DOMAIN
mkdir -p /logs/$DOMAIN
sudo chown -R apache:apache /logs/
echo "Creating vhost config for $DOMAIN..."

cat >/etc/httpd/sites-available/$DOMAIN.conf <<EOL
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	ServerName ${DOMAIN}
	ServerAlias www.${DOMAIN}
    DocumentRoot /var/www/${DOMAIN}
    <Directory /var/www/${DOMAIN}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
	ErrorLog /logs/${DOMAIN}/error.log
	CustomLog /logs/${DOMAIN}/access.log combined
</VirtualHost>
EOL
echo "Enabling $DOMAIN. Will probably tell you to restart Apache..."
sudo ln -s /etc/httpd/sites-available/$DOMAIN.conf /etc/httpd/sites-enabled/$DOMAIN.conf
echo "So let's restart apache..."
sudo service httpd restart
done
echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
sudo chown -R apache:apache /var/lib/php
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
service mailhog restart
service mysqld restart
service httpd restart
egrep "temporary password" /var/log/mysqld.log
