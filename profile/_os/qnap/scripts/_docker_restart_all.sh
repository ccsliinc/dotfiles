#!/bin/bash
if [[ -z "${DEBUG}" ]]; then
    DEBUG=false
fi

if [[ "$DEBUG" == "true" ]] ; then printf "\n\t%s\n\n" "DEBUG MODE ON" ; fi

if ! command -v jq &> /dev/null; then
    printf "%s\n" "jq command cannot be found please install."
    return 1
fi


DOCKER_FILE="$HOME/dockers.local"
DOCKER=$(jq "." "$DOCKER_FILE")

for row in $(echo "$DOCKER" | jq -r '.dockers | keys[]'); do
    if [ "$(jq -r ".dockers.$row.update" "$DOCKER_FILE")" = "true" ]; then
        #Restart Docker
        CONTAINER="$(jq -r ".dockers.$row.name" "$DOCKER_FILE")"
        printf "%s\n" "Restarting : $CONTAINER"
        docker restart "$CONTAINER"
    fi
done