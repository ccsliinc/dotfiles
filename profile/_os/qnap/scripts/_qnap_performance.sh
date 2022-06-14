#!/bin/sh

# Hal Daemon
sudo mv /sbin/hal_daemon /sbin/hal_daemon.disabled
sudo kill -9 "$(pidof hal_daemon)"

# Notification Center
sudo /etc/init.d/nc.sh force-stop

# QuLog
sudo /etc/init.d/qulog.sh force-stop

# Resource Monitor
sudo /etc/init.d/qpkg_res.sh stop