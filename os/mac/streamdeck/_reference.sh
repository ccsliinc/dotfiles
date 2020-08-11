#!/bin/sh
#open -a Terminal ~/
#echo "Hello World"

osascript -e 'tell app "Terminal"
    do script "echo hello"
end tell'