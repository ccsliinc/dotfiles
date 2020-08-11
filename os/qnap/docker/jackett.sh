#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=binhex/arch-jackett
NAME=Jackett

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e UMASK=000 \
  -e PUID=0 \
  -e PGID=0 \
  -v /share/Container/docker-appdata/jackett/data:/data \
  -v /share/Container/docker-appdata/jackett/config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.224 --mac-address=02:42:E2:C7:82:24 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
