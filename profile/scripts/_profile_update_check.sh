# shellcheck shell=bash

#BASEDIR=$(dirname "$0")
CURDIR=${PWD}

cd "$DOTFILESLOC" &> /dev/null || exit

git remote update

STATUS=$(git status -sb)

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")


if [[ "$STATUS" == *"behindd"* ]]; then
    echo "Looks like profile is out of date!"
    REPLY=$(bash -c 'read -e -p "Do you want to update the profile? [y/N]" tmp; echo $tmp')
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        git pull
    fi
fi


if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Up-to-date"
elif [ "$LOCAL" = "$BASE" ]; then
    echo "Need to pull"
    echo "Looks like profile is out of date!"
    REPLY=$(bash -c 'read -e -p "Do you want to update the profile? [y/N]" tmp; echo $tmp')
    if [[ ! $REPLY =~ ^[Yy]$ ]]
        echo "no pull"
    then
        echo "pull"
        git pull
        exec zsh
    fi
elif [ "$REMOTE" = "$BASE" ]; then
    echo "Need to push"
else
    echo "Diverged"
fi

#mv ~/.dotfiles/.dotfiles_location /home/.dotfiles_location
#mv /home/.dotfiles_location ./

cd "$CURDIR" || exit