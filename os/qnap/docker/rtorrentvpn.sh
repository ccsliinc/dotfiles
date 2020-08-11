#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=binhex/arch-rtorrentvpn
NAME=rTorrent

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e PHP_TZ=America/New_York \
  -e VPN_ENABLED=yes \
  -e VPN_USER=p6594961 \
  -e VPN_PASS=siM8bNfaMR \
  -e VPN_PROV=airvpn \
  -e STRICT_PORT_FORWARD=yes \
  -e ENABLE_PRIVOXY=no \
  -e ENABLE_AUTODL_IRSSI=yes \
  -e ENABLE_RPC2=yes \
  -e ENABLE_RPC2_AUTH=yes \
  -e ENABLE_WEBUI_AUTH=no \
  -e RPC2_USER=admin \
  -e RPC2_PASS=NzRhMjE4NjUzZDYw \
  -e WEBUI_USER=admin \
  -e WEBUI_PASS=NzRhMjE4NjUzZDYw \
  -e LAN_NETWORK=10.0.0.0/16 \
  -e NAME_SERVERS=8.8.8.8,8.8.4.4,209.222.18.222,84.200.69.80,37.235.1.174,1.1.1.1,209.222.18.218,37.235.1.177,84.200.70.40,1.0.0.1 \
  -v /share/CACHEDEV1_DATA/Rdownload:/data \
  -v /share/Container/docker-appdata/rtorrent:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.206 --mac-address=02:42:E2:C7:82:06 \
  --restart=always \
  --name $NAME \
  --privileged \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
