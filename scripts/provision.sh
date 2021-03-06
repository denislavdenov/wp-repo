#!/usr/bin/env bash


# ---------------------------------------------------------------------------------------------------------------------
# Variables & Functions
# ---------------------------------------------------------------------------------------------------------------------
#APP_DATABASE_NAME='wordpress'

echoTitle () {
    echo -e "\033[0;30m\033[42m -- $1 -- \033[0m"
}



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Virtual Machine Setup'
# ---------------------------------------------------------------------------------------------------------------------
# Update packages
sudo apt-get update -qq
sudo apt-get -y install git curl vim



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing and Setting: Apache'
# ---------------------------------------------------------------------------------------------------------------------
# Install packages
sudo apt-get install -y apache2 libapache2-mod-fastcgi apache2-mpm-worker

# linking Vagrant directory to Apache 2.4 public directory
# rm -rf /var/www
# ln -fs /vagrant /var/www

# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf

# Setup hosts file
VHOST=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/app/public"
      ServerName app.dev
      ServerAlias app.dev
      <Directory "/var/www/app/public">
        AllowOverride All
        Require all granted
      </Directory>
    </VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

sudo mkdir -p /var/www/app/public/

# Loading needed modules to make apache work
sudo a2enmod actions fastcgi rewrite
sudo service apache2 restart



# ---------------------------------------------------------------------------------------------------------------------
# echoTitle 'MYSQL-Database'
# ---------------------------------------------------------------------------------------------------------------------
# Setting MySQL (username: root) ~ (password: root)
#sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password root'
#sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password root'

# Installing packages
#sudo apt-get install -y mysql-server-5.6 mysql-client-5.6 mysql-common-5.6
#sudo apt-get update
#sudo apt-get install -y mysql-server

# Setup database
# mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME;";
# mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root';"
#mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root';"

# sudo service mysql restart

# Import SQL file
# cd /vagrant

# mysql -uroot -proot wordpress < conf/wordpress.sql

# sudo service mysql restart



# ---------------------------------------------------------------------------------------------------------------------
# echoTitle 'Maria-Database'
# ---------------------------------------------------------------------------------------------------------------------
# Remove MySQL if installed
# sudo service mysql stop
# apt-get remove --purge mysql-server-5.6 mysql-client-5.6 mysql-common-5.6
# apt-get autoremove
# apt-get autoclean
# rm -rf /var/lib/mysql/
# rm -rf /etc/mysql/

# Install MariaDB
# export DEBIAN_FRONTEND=noninteractive
# debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password root'
# debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password root'
# apt-get install -y mariadb-server

# Set MariaDB root user password and persmissions
# mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# Open MariaDB to be used with Sequel Pro
# sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/my.cnf

# Restart MariaDB
# sudo service mysql restart



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: PHP'
# ---------------------------------------------------------------------------------------------------------------------
# Add repository
yes '' | sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y python-software-properties software-properties-common

# Remove PHP5
# apt-get purge php5-fpm -y
# apt-get --purge autoremove -y

# Install packages
sudo apt-get install -y php7.1 php7.1-fpm
sudo apt-get install -y php7.1-mysql
sudo apt-get install -y mcrypt php7.1-mcrypt
sudo apt-get install -y php7.1-cli php7.1-curl php7.1-mbstring php7.1-xml php7.1-mysql
sudo apt-get install -y php7.1-json php7.1-cgi php7.1-gd php-imagick php7.1-bz2 php7.1-zip



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Setting: PHP with Apache'
# ---------------------------------------------------------------------------------------------------------------------
sudo apt-get install -y libapache2-mod-php7.1

# Enable php modules
# php71enmod mcrypt (error)

# Trigger changes in apache
sudo a2enconf php7.1-fpm
sudo service apache2 reload

# Packages Available:
# apt-cache search php7-*

sudo rm -f /etc/apache2/mods-enabled/dir.conf
sudo rm -f /etc/apache2/mods-available/dir.conf
sudo cp /vagrant/conf/dir.conf /etc/apache2/mods-enabled/dir.conf
sudo cp /vagrant/conf/dir.conf /etc/apache2/mods-available/dir.conf
sudo service apache2 restart

# ---------------------------------------------------------------------------------------------------------------------
# echoTitle 'Installing & Setting: X-Debug'
# ---------------------------------------------------------------------------------------------------------------------
# cat << EOF | sudo tee -a /etc/php/7.1/mods-available/xdebug.ini
# xdebug.scream=1
# xdebug.cli_color=1
# xdebug.show_local_vars=1
# EOF



# ---------------------------------------------------------------------------------------------------------------------
# Others
# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Node 6 and update NPM'
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install npm@latest -g

echoTitle 'Installing: Git'
apt-get install -y git

echoTitle 'Installing: Composer'
sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer



# ---------------------------------------------------------------------------------------------------------------------
# Others
# ---------------------------------------------------------------------------------------------------------------------
# Output success message
echoTitle "Your machine has been provisioned"
echo "-------------------------------------------"
echo "MySQL is available on port 3306 with username 'root' and password 'root'"
echo "(you have to use 127.0.0.1 as opposed to 'localhost')"
echo "Apache is available on port 80"
echo -e "Head over to http://192.168.56.56/wordpress/ to get started"