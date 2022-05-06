#!/bin/bash
if [[ -z "${DEBUG}" ]]; then
    DEBUG=false
fi

if [[ "$DEBUG" == "true" ]] ; then printf "\n\t%s\n\n" "DEBUG MODE ON" ; fi

if ! command -v jq &> /dev/null; then
    printf "%s\n" "jq command cannot be found please install."
    return 1
fi

echo "--------------------------------------------------------------------------"
echo "Started : $(date)"
echo "--------------------------------------------------------------------------"

DOCKER_FILE="$HOME/dockers.local"
DOCKER=$(jq "." "$DOCKER_FILE")

for row in $(echo "$DOCKER" | jq -r '.dockers | keys[]'); do
    if [ "$(jq -r ".dockers.$row.update" "$DOCKER_FILE")" = "true" ]; then
        #Check for updates
        /bin/bash _docker_update.sh "$row"
    fi
done

docker image prune -f -a
docker volume prune -f

echo ""
echo "Finished : $(date)"
echo "--------------------------------------------------------------------------"
