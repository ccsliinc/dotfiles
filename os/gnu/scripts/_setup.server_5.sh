#!/bin/sh

#Check Java
java -version

#Check Elasticsearch
curl -X GET 'http://localhost:9200'

sudo nano /etc/elasticsearch/elasticsearch.yml

#Configure PHP ini
sudo sed -i "s/memory_limit = .*/memory_limit = 2048M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/7.4/fpm/php.ini

sudo sed -i "s/memory_limit = .*/memory_limit = 2048M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/zlib.output_compression = .*/zlib.output_compression = on/" /etc/php/7.4/fpm/php.ini

#Configure Nginx
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/default


#Configure and Restart FPM
sudo cp conf/fpm-7.4/mmagento.conf /etc/php/7.4/fpm/pool.d/
sudo systemctl restart php7.4-fpm

#Setup SSL
sudo systemctl stop nginx
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chown www-data:www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt
sudo cp conf/letsencrypt.conf /etc/nginx/snippets/letsencrypt.conf

