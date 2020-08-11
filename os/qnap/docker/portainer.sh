#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=portainer/portainer
NAME=Portainer

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/portainer:/data \
  -p 9000:9000 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
