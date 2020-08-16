#!/bin/sh
. ~/.profile
_docker_image_check "pihole/pihole" "pihole"
_docker_image_check "cubebackup/cubebackup" "cubebackup"
_docker_image_check "binhex/arch-jackett" "jackett"
_docker_image_check "mariadb" "mariadb"
_docker_image_check "binhex/arch-medusa" "medusa"
_docker_image_check "benoitpodwinski/phpservermon" "phpservermon"
_docker_image_check "binhex/arch-radarr" "radarr"
_docker_image_check "odarriba/timemachine" "timemachine"
_docker_image_check "linuxserver/unifi-controller" "unificontroller"
_docker_image_check "blacklabelops/volumerize" "volumerize"
_docker_image_check "binhex/arch-rtorrentvpn" "rtorrent"
_docker_image_check "linuxserver/openvpn-as" "openvpn"
