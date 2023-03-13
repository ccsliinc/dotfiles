#!/bin/bash

current=$(date +%s)

if [[ -f ~/.update_brew ]]; then
    last_modified=$(stat -f %m ~/.update_brew)
else
    last_modified=0
fi

((time_difference="$current-$last_modified"))

if [[ $# -eq 1 ]] ; then

    while test $# -gt 0
    do
        case "$1" in
            --[fF]) echo "Forced Update"
                ;;
            --*) echo "Invalid Argument $1"
                echo "Try using --F"
                exit
                ;;
            *) echo "Invalid Argument $1"
                echo "Try using --F"
                exit
                ;;
        esac
        shift
    done
elif [[ $time_difference -gt 345600 ]]; then
    echo "Last Update Performed $(stat -f "%Sm" ~/.update_brew)"
    REPLY=$(bash -c 'read -e -p "Do you want to update brew? [y/N]" tmp; echo $tmp')
    #read -p "Do you want to update brew? [y/N]" -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit
    fi
else
    exit
fi

cd ~ || exit

# Update timestamp
touch ~/.update_brew

echo "## Backup System Settings"
echo "# Backup hosts file"
cp -f /etc/hosts ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Apps/hosts/
echo "# Backup brew and mas"
brew bundle dump
mv -f ~/Brewfile ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Apps/brew/
echo "# Backup global npm libraries"
npm list --global --parseable --depth=0 | sed '1d' | awk '{gsub(/\/.*\//,"",$1); print}' > ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Apps/npm/npm.txt
#xargs npm install --global < ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Apps/npm/npm.txt
echo "# Back composer global packages"
composer global show > ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Apps/composer/composer.txt

echo "## Begin Updates ##"
echo

echo
echo "## Homebrew Updates and Upgrades ##"
echo
brew update
brew upgrade
brew cleanup -s

echo
echo "## Homebrew Diagnostics ##"
echo
#now do diagnostics
brew doctor
brew missing

#atom upgrade
apm upgrade -c false

echo
echo "## App Store ##"
echo
#/opt/bin/updateCCTF.sh && terminal-notifier -message "git pull done :-)" -title "CCTF up to date"
echo "you can hit mas upgrade to upgrade theses apps from the app store:"
mas outdated
echo "install with: mas upgrade"

echo
echo "## NPM ##"
echo
# Update npm global
npm update -g

echo
echo "## Composer ##"
echo
# Update Composer global
composer global update

echo
echo "## End Updates ##"
#echo "did you think to launch gem update "
#echo "and pip ? pip freeze — local | grep -v ‘^\-e’ | cut -d = -f 1 | xargs pip install -U "
