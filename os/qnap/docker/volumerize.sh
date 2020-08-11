#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=blacklabelops/volumerize
NAME=Volumerize

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e "TZ=America/New_York" \
  -e "VOLUMERIZE_CACHE=/volumerize-cache" \
  -e "VOLUMERIZE_CONTAINERS=Pi-hole phpServerMon MariaDB Unifi Jackett Medusa Radarr rTorrent" \
  -e "VOLUMERIZE_FULL_IF_OLDER_THAN=7D" \
  -e "VOLUMERIZE_HOME=/etc/volumerize" \
  -e "VOLUMERIZE_JOBBER_TIME=0 0 3 * * *" \
  -e "VOLUMERIZE_SCRIPT_DIR=/opt/volumerize" \
  -e "VOLUMERIZE_SOURCE=/source" \
  -e "VOLUMERIZE_TARGET=file:///backup" \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/unifi:/source/unifi:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/jackett:/source/jackett:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/medusa:/source/medusa:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/radarr:/source/radarr:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/rtorrent:/source/rtorrent:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/pihole:/source/pihole:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/mariadb:/source/mariadb:ro \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/volumerize/backup:/backup	 \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/volumerize/cache:/volumerize-cache \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
