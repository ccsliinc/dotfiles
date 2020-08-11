#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=pihole/pihole
NAME=Pi-hole

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e "TZ=America/New_York" \
  -v /share/Container/docker-appdata/pihole/etc-pihole:/etc/pihole \
  -v /share/Container/docker-appdata/pihole/etc-dnsmasq.d:/etc/dnsmasq.d \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.201 --mac-address=02:42:E2:C7:82:01 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
