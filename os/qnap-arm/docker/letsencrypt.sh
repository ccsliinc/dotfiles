#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=linuxserver/letsencrypt
NAME=LetsEncrypt

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e "TZ=America/New_York" \
  -e "URL=ccsliinc-home.duckdns.org" \
  -e "VALIDATION=duckdns" \
  -e "DUCKDNSTOKEN=40c28a58-44ae-4d30-bca6-cf231b33ee92" \
  -v /share/Container/docker-appdata/letsencrypt:/config\
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
