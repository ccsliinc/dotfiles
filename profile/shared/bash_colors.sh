#!/bin/bash
# shellcheck disable=SC2034

if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/profile/shared/bash_colors.sh" ; fi

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


  # Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed