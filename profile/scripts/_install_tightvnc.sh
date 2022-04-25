#!/bin/bash
# Reference : https://www.reddit.com/r/Kalilinux/comments/leqx11/tutorial_raspberry_pi_kali_20204_headless_install/

# Update System
sudo apt update && sudo apt dist-upgrade -y

# Install VNC Packages
sudo apt install tightvncserver autocutsel dbus-x11

#netstat -tuna

vncserver :1
vncserver -kill :1

touch ~/.Xresources

cat << EOF > "/home/$(whoami)/.vnc/xstartup"
#!/bin/sh
xrdb $HOME/.Xresources
xsetroot -solid grey
autocutsel -fork
xhost + kali
# Fix to make GNOME work
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
EOF

read -r -d '' VNCBOOT << EOF2
#!/bin/sh
### BEGIN INIT INFO
# Provides: vncboot
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start VNC Server at boot time
# Description: Start VNC Server at boot time.
### END INIT INFO

USER=$(whoami)
HOME=/home/$(whoami)

export USER HOME

case "\$1" in
    start)
        echo "Starting VNCServer"
        su -l \$USER -c "/usr/bin/vncserver :1 -geometry 1280x720 -depth 16"

        #ssh connections only
        #su -l kali -c "/usr/bin/vncserver :1 -geometry 1280x720 -depth 16 -localhost -nolisten tcp"
    ;;

    stop)
        echo "Stopping VNCServer"
        su -l \$USER -c "/usr/bin/vncserver -kill :1"
    ;;

    *)
        echo "Usage: /etc/init.d/vncboot {start|stop}"
        exit 1
    ;;
esac

exit 0
EOF2

echo "$VNCBOOT" | sudo tee -a /etc/init.d/vncboot

sudo chmod 755 /etc/init.d/vncboot

sudo update-rc.d vncboot defaults

sudo service vncboot start

sudo service vncboot status
