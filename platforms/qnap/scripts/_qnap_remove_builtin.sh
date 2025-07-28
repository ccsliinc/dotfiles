#!/bin/sh

#Remove Malware Remover
echo "Path : $(getcfg MalwareRemover Install_Path -f /etc/config/qpkg.conf)"
sudo "$(getcfg MalwareRemover Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg MalwareRemover -f /etc/config/qpkg.conf
echo "Removed MalwareRemover"

#Remove Helpdesk
echo "Path : $(getcfg HelpDesk Install_Path -f /etc/config/qpkg.conf)"
sudo "$(getcfg HelpDesk Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg HelpDesk -f /etc/config/qpkg.conf
echo "Removed HelpDesk"

#Remove Multimedia Console
echo "Path : $(getcfg MultimediaConsole Install_Path -f /etc/config/qpkg.conf)"
sudo "$(getcfg MultimediaConsole Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg MultimediaConsole -f /etc/config/qpkg.conf
echo "Removed MultimediaConsole"

#Remove ResourceMonitor
echo "Path : $(getcfg ResourceMonitor Install_Path -f /etc/config/qpkg.conf)"
sudo "$(getcfg ResourceMonitor Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg ResourceMonitor -f /etc/config/qpkg.conf
echo "Removed ResourceMonitor"

#Remove QuLog
echo "Path : $(getcfg QuLog Install_Path -f /etc/config/qpkg.conf)"
sudo "$(getcfg QuLog Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg QuLog -f /etc/config/qpkg.conf
echo "Removed QuLog"

# # Stop the service before we begin the removal.
# if [ -x /etc/init.d/qulog.sh ]; then
# /etc/init.d/qulog.sh stop
# /bin/sleep 5
# /bin/sync
# fi

# # Package specific routines as defined in package_routines.
# {
# }

# # Remove QPKG directory, init-scripts, and icons.
# sudo /bin/rm -fr "/mnt/ext/opt/QuLog"
# sudo /bin/rm -f "/etc/init.d/qulog.sh"
# sudo /usr/bin/find /etc/rcS.d -type l -name 'QS*QuLog' | /usr/bin/xargs /bin/rm -f
# sudo /usr/bin/find /etc/rcK.d -type l -name 'QK*QuLog' | /usr/bin/xargs /bin/rm -f
# sudo /bin/rm -f "/home/httpd/RSS/images/QuLog.gif"
# sudo /bin/rm -f "/home/httpd/RSS/images/QuLog.gif"
# sudo /bin/rm -f "/home/httpd/RSS/images/QuLog.gif"

# # Package specific routines as defined in package_routines.
# {
#     # remove UI
#     # /bin/rm -rf /home/httpd/cgi-bin/qid/qlicenseRequest.cgi
#     # /bin/rm -rf /home/httpd/cgi-bin/qpkg/LicenseCenter
# }

# # Package specific routines as defined in package_routines.

#Remove QcloudSSLCertificate
echo "Path : $(getcfg QcloudSSLCertificate Install_Path -f /etc/config/qpkg.conf)"
sudo "$(getcfg QcloudSSLCertificate Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg QcloudSSLCertificate -f /etc/config/qpkg.conf
echo "Removed QcloudSSLCertificate"


# #Remove NotificationCenter
# echo "Path : $(getcfg QuLog Install_Path -f /etc/config/qpkg.conf)"
# sudo "$(getcfg QuLog Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
# sudo rmcfg QuLog -f /etc/config/qpkg.conf
# echo "Removed QuLog"


#Remove LicenseCenter
#/mnt/ext/opt/ResourceMonitor/.uninstall.sh
sudo "$(getcfg LicenseCenter Install_Path -f /etc/config/qpkg.conf)"/.uninstall.sh
sudo rmcfg LicenseCenter -f /etc/config/qpkg.conf
echo "Removed LicenseCenter"

# # Stop the service before we begin the removal.
# if [ -x /etc/init.d/LicenseCenter.sh ]; then
# /etc/init.d/LicenseCenter.sh stop
# /bin/sleep 5
# /bin/sync
# fi

# # Package specific routines as defined in package_routines.
# {
# }

# # Remove QPKG directory, init-scripts, and icons.
# /bin/rm -fr "/mnt/ext/opt/LicenseCenter"
# /bin/rm -f "/etc/init.d/LicenseCenter.sh"
# /usr/bin/find /etc/rcS.d -type l -name 'QS*LicenseCenter' | /usr/bin/xargs /bin/rm -f
# /usr/bin/find /etc/rcK.d -type l -name 'QK*LicenseCenter' | /usr/bin/xargs /bin/rm -f
# /bin/rm -f "/home/httpd/RSS/images/LicenseCenter.gif"
# /bin/rm -f "/home/httpd/RSS/images/LicenseCenter_80.gif"
# /bin/rm -f "/home/httpd/RSS/images/LicenseCenter_gray.gif"

# # Package specific routines as defined in package_routines.
# {
#     # remove UI
#     /bin/rm -rf /home/httpd/cgi-bin/qid/qlicenseRequest.cgi
#     /bin/rm -rf /home/httpd/cgi-bin/qpkg/LicenseCenter
# }

# # Package specific routines as defined in package_routines.
