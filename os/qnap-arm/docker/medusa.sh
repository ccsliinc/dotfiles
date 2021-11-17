#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=binhex/arch-medusa
NAME=Medusa

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e UMASK=000 \
  -e PUID=0 \
  -e PGID=0 \
  -v /share/Media/Series:/media1 \
  -v "/share/Media/Series (Untracked):/media2" \
  -v /share/Rdownload/complete/medusa:/data \
  -v /share/Container/docker-appdata/medusa:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.222 --mac-address=02:42:E2:C7:82:22 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
