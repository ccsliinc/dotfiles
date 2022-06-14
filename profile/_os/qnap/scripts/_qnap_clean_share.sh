#!/bin/bash
if [[ -z "${DEBUG}" ]]; then
    DEBUG=false
fi

FOLDER="/share/CACHEDEV2_DATA/"

if [[ $# -eq 1 ]];then
    while test $# -gt 0
    do
        case "$1" in
            --[dD]elete) echo "Forced Update"
                find $FOLDER -iname "._*" -type f -delete;
                find $FOLDER -iname "__MACOSX" -type f -delete;
                find $FOLDER -iname ".DS_Store" -type f -delete;
                find $FOLDER -iname "Thumbs.db" -type f -delete;
                find $FOLDER -iname "Thumbs.db:encryptable" -type f -delete;
                exit 1
                ;;
        esac
        shift
    done
else
    printf "%s\n\n" "Testing Mode"
    find $FOLDER -iname "._*" -type f;
    find $FOLDER -iname "__MACOSX" -type f;
    find $FOLDER -iname ".DS_Store" -type f
    find $FOLDER -iname "Thumbs.db" -type f;
    find $FOLDER -iname "Thumbs.db:encryptable" -type f;
fi