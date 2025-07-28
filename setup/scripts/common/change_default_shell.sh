#!/bin/bash

#OPTERR=0

usage() {
    echo "$(basename "$0") [-h] [-s /bin/zsh] -- changes the default shell.

where:
    -s  set the default shell (default: /bin/zsh)
    -h  show this help text" 1>&2
}

# Function: Exit with error.
exit_abnormal() {
    echo ""
    usage
    exit 1
}

# shellcheck source=../../../base/.profile
source ~/.dotfiles/base/.profile

if [[ $OS == "qnap" ]]; then
    shell="/opt/bin/zsh"
else
    shell="/bin/zsh"
fi


while getopts "hs:" flag; do
    case "${flag}" in
        h)  usage
            exit 0
            ;;
        s)  shell=${OPTARG}
            ;;
        :)  # If expected argument omitted:
            exit_abnormal # Exit abnormally.
            ;;
        *)  exit_abnormal # Exit abnormally.
            ;;
    esac
done

echo "$OS"


# Check if shell exists.
if [[ ! -x $shell ]]; then
    echo "Shell $shell does not exist." 1>&2
    exit 1
fi

if [[ $OS == "qnap" ]]; then
    sudo usermod -s "$shell" "$(whoami)"
    exec $shell
else
    sudo chsh -s "$shell" "$(whoami)"
    exec "$shell"
fi