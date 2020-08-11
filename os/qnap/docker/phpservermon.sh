#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=benoitpodwinski/phpservermon
NAME=phpServerMon

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  --env PSM_BASE_URL=http://10.0.1.209/ \
  --env PSM_DB_HOST=10.0.1.208 \
  --env PSM_DB_NAME=phpservermon \
  --env PSM_DB_USER=phpservermon \
  --env PSM_DB_PASS=password \
  --env PSM_DB_PREFIX=abc_ \
  --env PHP_TIMEZONE=America/New_York \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.209 --mac-address=02:42:E2:C7:82:09 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
