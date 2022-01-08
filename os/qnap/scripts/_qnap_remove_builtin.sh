#!/bin/sh

#Remove Malware Remover
#/share/CACHEDEV1_DATA/.qpkg/MalwareRemover/.uninstall.sh
"$(getcfg MalwareRemover Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
rmcfg MalwareRemover -f /etc/config/qpkg.conf
echo "Removed MalwareRemover"

#Remove Helpdesk
#/mnt/HDA_ROOT/update_pkg/helpdesk/.uninstall.sh
"$(getcfg HelpDesk Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
rmcfg HelpDesk -f /etc/config/qpkg.conf
echo "Removed HelpDesk"

#Remove Multimedia Console
#/share/CACHEDEV1_DATA/.qpkg/MultimediaConsole/.uninstall.sh
"$(getcfg MultimediaConsole Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
rmcfg MultimediaConsole -f /etc/config/qpkg.conf
echo "Removed MultimediaConsole"