#!/bin/bash
DEBUG=false

if [[ "$DEBUG" == "true" ]] ; then printf "\n\t%s\n\n" "DEBUG MODE ON" ; fi

if [ "$#" -ne 1 ]; then
    printf "%s\n\n" "Docker image not supplied!"
    printf "%s\n%s\n\n" "Example:" "_docker_check_image_latest.sh pihole/pihole"
    exit 9
fi

IMAGE="$1"
VER="latest"

if [[ "$DEBUG" == "true" ]] ; then printf "%s\n" "Fetching Docker Hub token..." ; fi

if [[ "$IMAGE" == *"/"*"/"* ]] ; then
    IMAGE="$(cut -d "/" -f2 <<< "$IMAGE")/$(cut -d "/" -f3 <<< "$IMAGE")"
fi

token=$(curl --silent "https://auth.docker.io/token?scope=repository:$IMAGE:pull&service=registry.docker.io" | jq -r '.token')

if [[ "$IMAGE" == *":"* ]] ; then
    VER="$(cut -d ":" -f2 <<< "$IMAGE")"
    IMAGE="$(cut -d ":" -f1 <<< "$IMAGE")"
fi

if [[ "$DEBUG" == "true" ]] ; then printf "%s\n" "Fetching remote digest..." ; fi

digest=$(curl --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
-H "Authorization: Bearer $token" \
"https://registry.hub.docker.com/v2/$IMAGE/manifests/$VER" | jq -r '.config.digest')

if [[ "$DEBUG" == "true" ]] ; then printf "%s\n" "Fetching local digest..." ; fi

#local_digest=$(docker images -q --no-trunc "$IMAGE\:$VER")
local_digest=$(docker images -q --no-trunc "$1")

if [[ "$DEBUG" == "true" ]] ; then printf "%s\n" "$digest : $local_digest" ; fi

if [[ "$digest" == "null" ]] ; then
    printf "%s\n" "'$IMAGE' not found."
    exit 9
elif [ "$digest" != "$local_digest" ] ; then
    printf "%s\n" "Update available for '$IMAGE'."
    exit 1
else
    printf "%s\n" "'$IMAGE' is up to date."
    exit 0
fi