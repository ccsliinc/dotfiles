#!/bin/bash

sub-submenu() {
    echo -ne "
SUB-SUBMENU
1) GOOD MORNING
2) GOOD AFTERNOON
3) Go Back to SUBMENU
4) Go Back to MAIN MENU
0) Exit
Choose an option:  "

    read -r ans
    case $ans in
    1)
        fn_goodmorning
        sub-submenu
        ;;
    2)
        fn_goodafternoon
        sub-submenu
        ;;
    3)
        submenu
        ;;
    4)
        mainmenu
        ;;
    0)
        echo "Bye bye."
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}