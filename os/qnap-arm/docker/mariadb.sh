#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=mariadb
NAME=MariaDB

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  --env MYSQL_ROOT_PASSWORD=password \
  --env MYSQL_DATABASE=phpservermon \
  --env MYSQL_USER=phpservermon \
  --env MYSQL_PASSWORD=password \
  -v /share/Container/docker-appdata/mariadb:/var/lib/mysql:rw \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.208 --mac-address=02:42:E2:C7:82:08 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
