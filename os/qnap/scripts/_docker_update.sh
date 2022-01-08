#!/bin/bash
DEBUG=true

if ! command -v jq &> /dev/null; then
    echo "jq command cannot be found please install."
    return 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: Must supply a docker to update"
    return 1
fi

DOCKER_FILE="$HOME/dockers.local"
DOCKER=$1
DOCKER=$(jq ".dockers.$DOCKER" "$DOCKER_FILE")

if [[ "$DEBUG" == "true" ]] ; then echo -n "DOCKER INFO : \n $DOCKER" ; fi




