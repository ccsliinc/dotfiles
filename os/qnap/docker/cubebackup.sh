#!/usr/bin/env bash
source /share/CACHEDEV1_DATA/custom/.bashrc_custom

IMAGE=cubebackup/cubebackup
NAME=CubeBackup

docker pull $IMAGE
docker stop $NAME
docker rm $NAME
docker run -it -d \
  -e "TZ=America/New_York" \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/cubebackup/cubebackup_data:/gsuite_backup \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/cubebackup/cubebackup_index:/cube_index \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/cubebackup/cubebackup_config/db:/opt/cubebackup/db \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/cubebackup/cubebackup_config/locks:/opt/cubebackup/locks \
  -v /share/CACHEDEV1_DATA/Container/docker-appdata/cubebackup/cubebackup_config/log:/opt/cubebackup/log \
  --net=qnet-static-eth0-ccd67c --ip=10.0.1.207 --mac-address=02:42:E2:C7:82:07 \
  --restart=always \
  --name $NAME \
  $IMAGE

ID=$(docker inspect --format="{{.Id}}" $NAME)

curl -sq -XPOST -c cookies.txt -d "username=$DOCKER_USERNAME&password=$DOCKER_PASSWORD" http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/login
curl -sq -XPUT -b cookies.txt http://$DOCKER_HOST:$DOCKER_PORT/containerstation/api/v1/container/docker/$ID/autostart/on
