#!/bin/bash

sudo find . -type f -exec chmod 664 {} \;
sudo find . -type d -exec chmod 775 {} \;
sudo find var pub/static pub/media app/etc -type f -exec chmod g+w {} \;
sudo find var pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
sudo chmod u+x bin/magento