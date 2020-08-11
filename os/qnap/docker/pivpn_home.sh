#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=linuxserver/openvpn-as
NAME=OpenVPN
NETWORK=qnet-static-eth0-ccd67c
IP=10.0.1.225
MAC=02:42:E2:C7:82:25

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e "TZ=America/New_York" \
  -v /share/Container/docker-appdata/openvpn:/config \
  --net=$NETWORK --ip=$IP --mac-address=$MAC \
  --restart=always \
  --name $NAME \
  --privileged \
  $IMAGE

#  -v /share/Container/docker-appdata/letsencrypt/keys/letsencrypt:/config/etc/web-ssl/letsencrypt:ro \

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on


