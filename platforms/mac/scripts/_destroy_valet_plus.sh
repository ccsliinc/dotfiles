#!/bin/bash
    #styles
    VP_NONE='\033[00m'
    VP_RED='\033[01;31m'
    VP_GREEN='\033[01;32m'
    VP_YELLOW='\033[01;33m'
    VP_PURPLE='\033[01;35m'
    VP_CYAN='\033[01;36m'
    VP_WHITE='\033[01;37m'
    VP_BOLD='\033[1m'
    VP_UNDERLINE='\033[4m'

    # clear the screen
    clear

    # cache sudo password so it will only need to be entered once.
    echo -e "${VP_RED}${VP_BOLD}You may be asked to enter your password twice….${VP_NONE}"
    sudo -v

    # update homebrew
    brew update

    # upgrade homebrew formulas
    brew upgrade

    # cleanup mess
    brew doctor
    brew cleanup
    brew prune

    # stop Valet
    #==================
    valet stop
    sudo valet stop
    composer global remove laravel/valet
    composer global remove weprovide/valet-plus
    brew services stop  --all

    # Uninstall dnsmasq
    #==================
    sudo launchctl unload homebrew.mxcl.dnsmasq.plist
    brew uninstall dnsmasq
    sudo rm -rf /usr/local/etc/dnsmasq.conf
    sudo rm -rf /usr/local/Cellar/dnsmasq
    sudo rm -rf /usr/local/opt/dnsmasq
    sudo rm -rf /etc/resolver
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    sudo killall dnsmasq

    # Uninstall nginx
    #================
    sudo launchctl unload homebrew.mxcl.nginx.plist
    brew uninstall nginx
    sudo rm -rf /usr/local/etc/nginx/
    sudo rm -rf /usr/local/Cellar/nginx
    sudo rm -rf /usr/local/opt/nginx
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
    sudo killall nginx
    killall nginx

    # Uninstall PHP72
    #================
    sudo launchctl unload homebrew.mxcl.php72.plist
    brew uninstall php72 php72-mcrypt php72-xdebug php72-opcache php72-apcu php72-geoip php72-intl php72-opcache n98-magerun n98-magerun2
    sudo rm -rf /usr/local/etc/php
    sudo rm -rf /usr/local/Cellar/php72*
    sudo rm -rf /usr/local/opt/php72*
    sudo rm -rf /usr/local/opt/php72
    sudo rm -rf /usr/local/sbin/php*
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.php72.plist
    sudo killall php-fpm

    # Uninstall PHP71
    #================
    sudo launchctl unload homebrew.mxcl.php71.plist
    brew uninstall php71 php71-mcrypt php71-xdebug php71-opcache php71-apcu php71-geoip php71-intl php71-opcache n98-magerun n98-magerun2
    sudo rm -rf /usr/local/etc/php
    sudo rm -rf /usr/local/Cellar/php71*
    sudo rm -rf /usr/local/opt/php71*
    sudo rm -rf /usr/local/opt/php71
    sudo rm -rf /usr/local/sbin/php*
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.php71.plist
    sudo killall php-fpm

    # Uninstall PHP70
    #================
    sudo launchctl unload homebrew.mxcl.php70.plist
    brew uninstall php70 php70-mcrypt php70-xdebug php70-opcache php70-apcu php70-geoip php70-intl php70-opcache n98-magerun n98-magerun2
    sudo rm -rf /usr/local/etc/php
    sudo rm -rf /usr/local/Cellar/php70*
    sudo rm -rf /usr/local/opt/php70*
    sudo rm -rf /usr/local/opt/php70
    sudo rm -rf /usr/local/sbin/php*
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.php70.plist
    sudo killall php-fpm

    # Uninstall PHP56
    #================
    sudo launchctl unload homebrew.mxcl.php56.plist
    brew uninstall php56 php56-mcrypt php56-xdebug php56-opcache php56-apcu php56-geoip php56-intl php56-opcache n98-magerun n98-magerun2
    sudo rm -rf /usr/local/etc/php
    sudo rm -rf /usr/local/Cellar/php56*
    sudo rm -rf /usr/local/opt/php56*
    sudo rm -rf /usr/local/opt/php56
    sudo rm -rf /usr/local/sbin/php*
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.php56.plist
    sudo killall php-fpm

    # Uninstall Mysql
    #================
    brew uninstall mysql
    brew cleanup
    sudo rm /usr/local/my.cnf
    sudo rm /usr/local/etc/my.cnf
    sudo rm /usr/local/mysql
    sudo rm -rf /usr/local/var/mysql
    sudo rm -rf /usr/local/mysql*
    sudo rm ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    sudo rm -rf /Library/StartupItems/MySQLCOM
    sudo rm -rf /Library/PreferencePanes/My*
    sudo rm -rf /usr/local/Cellar/mysql
    sudo rm -rf /usr/local/var/mysql

    launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    rm ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

    rm -rf ~/Library/PreferencePanes/My*
    sudo rm -rf /Library/Receipts/mysql*
    sudo rm -rf /Library/Receipts/MySQL*
    sudo rm -rf /private/var/db/receipts/*mysql*
    sudo killall mysqld

    # Uninstall Valet
    #================
    brew uninstall mailhog
    brew uninstall redis
    sudo launchctl unload homebrew.mxcl.mailhog.plist
    sudo launchctl unload homebrew.mxcl.redis.plist
    sudo rm /Library/LaunchDaemons/homebrew.mxcl.*
    sudo killall mailhog
    sudo killall redis

    sudo rm -rf ~/.valet
    sudo rm -rf ~/.composer/vendor/weprovide/
    brew services stop  --all

    # remove composer from path
    before='export PATH="$PATH:$HOME/.composer/vendor/bin"'
    after=''
    sed -i  "s#${before}##g" ~/.bash_profile

    # update homebrew
    brew update
    # upgrade homebrew formulas
    brew upgrade
    # cleanup mess
    brew doctor
    brew cleanup
    brew prune

    echo " "
    echo -e "${VP_GREEN}${VP_BOLD}user brew services list to see if any services are running${VP_NONE}"
    brew services list

    echo " "
    echo -e "${VP_GREEN}${VP_BOLD}use ps to see if any process's are running${VP_NONE}"
    ps  aux | grep DesktopServer.app       | grep -v grep| head -1
    ps  aux | grep "Local by Flywheel.app" | grep -v grep| head -1
    ps  aux | grep -i "xamp"               | grep -v grep| head -1
    ps  aux | grep -i "mamp"               | grep -v grep| head -1
    ps  aux | grep dnsmasq                 | grep -v grep| head -1
    ps  aux | grep nginx                   | grep -v grep| head -1
    ps  aux | grep php                     | grep -v grep| head -1
    ps  aux | grep mysql                   | grep -v grep| head -1

    echo -e "${VP_RED}${VP_BOLD}REBOOT NOW BEFORE YOU RUN THE INSTALL${VP_NONE}"