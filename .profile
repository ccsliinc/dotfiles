# Colors
##############################
       LGRAY="\\033[1;30m"
        LRED="\\033[1;31m"
      LGREEN="\\033[1;32m"
     LYELLOW="\\033[1;33m"
       LBLUE="\\033[1;34m"
     LPURPLE="\\033[1;35m"
       LCYAN="\\033[1;36m"
      LWHITE="\\033[1;37m"
       DGRAY="\\033[0;30m"
        DRED="\\033[0;31m"
      DGREEN="\\033[0;32m"
     DYELLOW="\\033[0;33m"
       DBLUE="\\033[0;34m"
     DPURPLE="\\033[0;35m"
       DCYAN="\\033[0;36m"
      DWHITE="\\033[0;37m"
     NOCOLOR="\\033[0m"

    PS_LGRAY="\[${LGRAY}\]"
     PS_LRED="\[${LRED}\]"
   PS_LGREEN="\[${LGREEN}\]"
  PS_LYELLOW="\[${LYELLOW}\]"
    PS_LBLUE="\[${LBLUE}\]"
  PS_LPURPLE="\[${LPURPLE}\]"
    PS_LCYAN="\[${LCYAN}\]"
   PS_LWHITE="\[${LWHITE}\]"
    PS_DGRAY="\[${DGRAY}\]"
     PS_DRED="\[${DRED}\]"
   PS_DGREEN="\[${DGREEN}\]"
  PS_DYELLOW="\[${DYELLOW}\]"
    PS_DBLUE="\[${DBLUE}\]"
  PS_DPURPLE="\[${DPURPLE}\]"
    PS_DCYAN="\[${DCYAN}\]"
   PS_DWHITE="\[${DWHITE}\]"
  PS_NOCOLOR="\[${NOCOLOR}\]"


[[ -f ~/.exports ]] && source ~/.exports
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.functions ]] && source ~/.functions


# Print out some stuff
#############################
    clear
    echo -en "$LBLUE"
    echo "_________________________________________________________________________"
    echo -en "$LCYAN"
    date
    echo -en "$NOCOLOR"

    if [[ -x "$(command -v fortune)" ]] ; then
      echo -en "$DPURPLE"
        echo
        fortune
        echo
    fi
    echo -e "${LBLUE}Welcome to: ${LRED}`hostname`${LBLUE}"
    [[ -r /etc/redhat-release ]] && cat /etc/redhat-release
    [[ -x "$(command -v lsb_release)" ]] && lsb_release -d | awk -F ":" '{print $NF}' | awk '{$1=$1};1'
    [[ -x "$(command -v system_profiler)" ]] && system_profiler SPSoftwareDataType | grep 'System Version' | awk -F ":" '{print $NF}' | awk '{$1=$1};1'

    uname -s -r -m -p
    echo -en "$LGREEN"
    uptime

    echo -en "$LBLUE"
    echo "_________________________________________________________________________"
    # change color to normal
    echo -en "$NOCOLOR"
    echo
#############################
# End print

# These should be the last 2 lines of the file
# Don't make edits below this
[[ -f ~/.dotfiles/os/${OS}/.profile ]] && source ~/.dotfiles/os/${OS}/.profile
[[ -f ~/.profile.local ]] && source ~/.profile.local
