#!/bin/bash
DEBUG=false

if [[ "$DEBUG" == "true" ]] ; then printf "\n\t%s\n\n" "DEBUG MODE ON" ; fi

if ! command -v jq &> /dev/null; then
    printf "%s\n" "jq command cannot be found please install."
    return 1
fi

if [ "$#" -gt 2 ]; then
    printf "%s\n%s\n\n" "Must supply a docker to update!" "This should be a from the dockers.local list."
    printf "%s\n%s%s\n\n" "Example:" "_docker_update.sh pihole" "_docker_update.sh pihole --f"
    exit 9
fi

DOCKER_FILE="$HOME/dockers.local"
DOCKER=$1
DOCKER=$(jq ".dockers.$DOCKER" "$DOCKER_FILE")

if [[ "$DEBUG" == "true" ]] ; then printf "%s\n%s\n" "DOCKER INFO :" "$DOCKER" ; fi

if [[ -z "$DOCKER" ]] || [[ "$DOCKER" == "null" ]] ; then
    printf "%s\n" "Cannot find docker, please check dockers.local file."
    exit 1
else
    IMAGE=$(echo "$DOCKER" | jq -r .image)
    NAME=$(echo "$DOCKER" | jq -r .name)
    NETWORK=$(jq -r ".network" "$DOCKER_FILE")
    IP=$(echo "$DOCKER" | jq -r .ip)
    MAC=$(echo "$DOCKER" | jq -r .mac)
    ENV=""
    VOL=""
    NET=""
    EXTRA=""
    CMD="docker run -it -d \
        ~ENV~ \
        ~VOL~ \
        ~NET~ \
        --restart=always \
        --name $NAME \
        ~EXTRA~ \
        $IMAGE"
            
    for row in $(echo "$DOCKER" | jq -r '.env[]? | @base64'); do
        ENV="$ENV -e \"$(echo "${row}" | base64 -i --decode)\""
    done

    for row in $(echo "$DOCKER" | jq -r '.vol[]? | @base64'); do
        VOL="$VOL -v \"$(echo "${row}" | base64 -i --decode)\""
    done

    for row in $(echo "$DOCKER" | jq -r '.ext[]? | @base64'); do
        EXTRA="$EXTRA $(echo "${row}" | base64 -i --decode)"
    done

    if [ "$IP" != "null" ]; then
        NET="--net=$NETWORK --ip=$IP --mac-address=$MAC"
    fi

    CMD=${CMD/~ENV~/$ENV}
    CMD=${CMD/~VOL~/$VOL}
    CMD=${CMD/~EXTRA~/$EXTRA}
    CMD=${CMD/~NET~/$NET}
    CMD=$(echo "$CMD"| tr -s " ")

    if [[ "$DEBUG" == "true" ]] ; then printf "\n%s\n%s\n\n" "COMMAND" "$CMD"; fi

    #Check if there is an update
    /bin/bash _docker_check_image_latest.sh "$IMAGE"

    if [ $? == 1 ] || [ "$2" == "--f" ]; then
        printf "%s\n" "Updating docker '$NAME'.";
        eval docker pull "$IMAGE"
        if [ ! "$(docker ps -a -q -f name='$NAME')" ]; then
            eval docker stop "$NAME"
            eval docker rm "$NAME"
        fi

        for row in $(echo "$DOCKER" | jq -r '.prereq[]? | @base64'); do
            TMPCMD=$(echo "${row}" | base64 -i --decode)
            eval "$TMPCMD"
        done

        eval "$CMD"
    else
        printf "%s\n" "Docker '$NAME' does need to be updated.";
    fi
fi

exit 0