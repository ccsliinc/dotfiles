#!/bin/sh

#Initial Setup

# Change Timezone
sudo timedatectl set-timezone America/New_York

# Update Server
sudo apt update -y && sudo apt upgrade -y

# Install Node
sudo apt install -y nodejs npm

# Install Tools
sudo apt install -y unzip git net-tools vim

# Install Web Server Software
sudo apt install -y certbot nginx mysql-server

# Install 

sudo apt install -y \
    php7.4-fpm \
    php7.4-bcmath \
    php7.4-common \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-json \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-opcache \
    php7.4-readline \
    php7.4-soap \
    php7.4-tidy \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    php7.4-cli 


#Install Composer

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php

# specific version
#sudo php composer-setup.php --version=1.10.3 --install-dir=/usr/local/bin --filename=composer

php -r "unlink('composer-setup.php');"

#Install Java and Elastic Search
sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get install -y openjdk-8-jdk

#Install Redis
apt-get install -y redis-server

#Elasticsearch
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update -y && sudo apt install -y elasticsearch



