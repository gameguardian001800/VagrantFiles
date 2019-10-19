# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.4"
  config.vm.hostname = "centos7"

  # config.vm.network "private_network", ip: "192.168.39.11"
  # config.vm.synced_folder ".html", "/var/www/html"
  # config.vbguest.auto_update = false
  
  # config.vm.provider "virtualbox" do |vb|
  #  vb.name = "Magento2"
  #  vb.memory = "2048"
  #  vb.cpus = 2
  # end
  
    config.vm.provision "shell", inline: <<-SHELL
      yum update
      yum upgrade -y
      yum install -y yum-utils
      yum install -y nano
      yum install -y git
      yum install -y wget
      yum install -y zip
      yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
      yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
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
ExecStart=/usr/bin/env /usr/local/bin/mailhog > /dev/null 2>&1 &
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
      sudo sed -i 's/sendmail_path = \/usr\/sbin\/sendmail -t -i/sendmail_path = \/usr\/local\/bin\/mailhog/g' /etc/php.ini 
      sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php.ini 
      sudo sed -i 's/max_input_time = 60/max_input_time = 1800/g' /etc/php.ini 
      sudo sed -i 's/max_execution_time = 30/max_execution_time = 1800/g' /etc/php.ini 
      sudo sed -i 's/User apache/User vagrant/g' /etc/httpd/conf/httpd.conf 
      sudo sed -i 's/Group apache/Group vagrant/g' /etc/httpd/conf/httpd.conf
      sudo sed -i 's/SELINUX=permissive/SELINUX=disable/g' /etc/sysconfig/selinux
      sudo sed -i 's/SELINUX=enforcing/SELINUX=disable/g' /etc/sysconfig/selinux
      service mailhog restart
      service mysqld restart
      service httpd restart
      egrep "temporary password" /var/log/mysqld.log
    SHELL
end

# Run mysql_secure_installation after installing
# Check rewrite_mod and SeLinux Permission if you can't access your server
# Make sure you set an IP address on this vagrant file
# Make sure you have shared folders too