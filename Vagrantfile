# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/centos-7.7"
  config.vm.hostname = "centos7"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.39.11"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder "dev", "/var/www/dev.devlearnground.com"
  config.vm.synced_folder "stg", "/var/www/stg.devlearnground.com"
  config.vm.synced_folder "pro", "/var/www/devlearnground.com"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
    vb.name = "Bento7.7"
    vb.memory = "8192"
    vb.cpus = 4
   end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
    config.vm.provision "shell", inline: <<-SHELL
      yum update
      yum upgrade -y
      yum install -y yum-utils nano git wget zip https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm http://rpms.remirepo.net/enterprise/remi-release-7.rpm
      yum-config-manager --enable remi-php72
      yum -y install php72-php php-pdo php-mysqlnd php-opcache php-zip php-xml php-gd php-devel php-mysql php-intl php-mbstring php-bcmath php-json php-iconv php-soap
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
      sudo sed -i 's,sendmail_path = /usr/sbin/sendmail -t -i,sendmail_path = /usr/local/bin/mailhog,g' /etc/php.ini 
      sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php.ini 
      sudo sed -i 's/max_input_time = 60/max_input_time = 1800/g' /etc/php.ini 
      sudo sed -i 's/max_execution_time = 30/max_execution_time = 1800/g' /etc/php.ini 
      sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux 

      DOMAINS=("dev.devlearnground.com" "stg.devlearnground.com" "devleanrground.com")
        mkdir /etc/httpd/sites-available
        mkdir /etc/httpd/sites-enabled

        ## Loop through all sites
        for ((i=0; i < ${#DOMAINS[@]}; i++)); do

            ## Current Domain
            DOMAIN=${DOMAINS[$i]}

            echo "Creating directory for $DOMAIN..."
            mkdir -p /var/www/$DOMAIN

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
	ErrorLog logs/${DOMAIN}/error.log
	CustomLog logs/${DOMAIN}/access.log combined
</VirtualHost>
EOL

            echo "Enabling $DOMAIN. Will probably tell you to restart Apache..."
            sudo ln -s /etc/httpd/sites-available/$DOMAIN.conf /etc/httpd/sites-enabled/$DOMAIN.conf

            echo "So let's restart apache..."
            sudo service httpd restart

        done

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
