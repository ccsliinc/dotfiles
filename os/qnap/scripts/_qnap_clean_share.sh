#!/bin/bash
#DEBUG=true

FOLDER="/share/CACHEDEV1_DATA/"

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
                return 1
                ;;
        esac
        shift
    done
else
    echo "nothing"
    find $FOLDER -iname "._*" -type f;
    find $FOLDER -iname "__MACOSX" -type f;
    find $FOLDER -iname ".DS_Store" -type f
    find $FOLDER -iname "Thumbs.db" -type f;
    find $FOLDER -iname "Thumbs.db:encryptable" -type f;
fi