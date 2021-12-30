#!/bin/bash
DEBUG=true

IMAGE="$1"
#COMMAND="$2"
VER="latest"

if [[ "$DEBUG" == "true" ]] ; then echo -n "Fetching Docker Hub token..." ; fi

token=$(curl --silent "https://auth.docker.io/token?scope=repository:$IMAGE:pull&service=registry.docker.io" | jq -r '.token')

if [[ "$IMAGE" == *":"* ]] ; then
    VER="$(cut -d ":" -f2 <<< "$IMAGE")"
    IMAGE="$(cut -d ":" -f1 <<< "$IMAGE")"
fi

if [[ "$DEBUG" == "true" ]] ; then echo -n "Fetching remote digest..." ; fi

digest=$(curl --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
-H "Authorization: Bearer $token" \
"https://registry.hub.docker.com/v2/$IMAGE/manifests/$VER" | jq -r '.config.digest')

if [[ "$DEBUG" == "true" ]] ; then echo -n "Fetching local digest..." ; fi

local_digest=$(docker images -q --no-trunc "$IMAGE\:$VER")

if [[ "$DEBUG" == "true" ]] ; then echo -n "$digest : $local_digest" ; fi

if [ "$digest" != "$local_digest" ] ; then
    echo -n "Update available."
    exit 1
    #_docker_update "$COMMAND"
else
    echo "Up to date."
    exit 0
fi