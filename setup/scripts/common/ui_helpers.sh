#!/bin/bash
# Modern UI helper functions for dotfiles setup

# shellcheck source=../../../base/shared/bash_colors.sh
source "$HOME/.dotfiles/base/shared/bash_colors.sh" &> /dev/null

# Get terminal dimensions
get_terminal_size() {
    local cols rows
    if command -v tput >/dev/null 2>&1; then
        cols=$(tput cols 2>/dev/null || echo 80)
        rows=$(tput lines 2>/dev/null || echo 24)
    else
        cols=${COLUMNS:-80}
        rows=${LINES:-24}
    fi
    echo "$cols $rows"
}

# Draw a modern box with title
draw_box() {
    local title="$1"
    local content="$2"
    local width="${3:-60}"
    
    # Top border with title
    printf "${BICyan}${BOX_TL}"
    local title_len=${#title}
    local padding=$(( (width - title_len - 4) / 2 ))
    
    for ((i=0; i<padding; i++)); do printf "${BOX_H}"; done
    printf " ${BIWhite}${title}${BICyan} "
    for ((i=0; i<padding; i++)); do printf "${BOX_H}"; done
    
    # Adjust for odd widths
    if (( (width - title_len - 4) % 2 != 0 )); then
        printf "${BOX_H}"
    fi
    printf "${BOX_TR}${Color_Off}\n"
    
    # Content lines - properly handle each line
    local content_width=$((width - 4))
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && line=" "  # Handle empty lines
        
        # Calculate actual display length (without color codes)
        local display_line="$line"
        local display_len=${#display_line}
        
        if [[ $display_len -le $content_width ]]; then
            # Line fits, pad to exact width
            local padding_needed=$((content_width - display_len))
            printf "${BICyan}${BOX_V}${Color_Off} %s" "$display_line"
            printf "%*s" "$padding_needed" ""
            printf " ${BICyan}${BOX_V}${Color_Off}\n"
        else
            # Line too long, truncate
            local truncated="${display_line:0:$content_width}"
            printf "${BICyan}${BOX_V}${Color_Off} %s ${BICyan}${BOX_V}${Color_Off}\n" "$truncated"
        fi
    done <<< "$content"
    
    # Bottom border
    printf "${BICyan}${BOX_BL}"
    for ((i=0; i<width-2; i++)); do printf "${BOX_H}"; done
    printf "${BOX_BR}${Color_Off}\n"
}

# Progress bar
show_progress() {
    local current="$1"
    local total="$2" 
    local width="${3:-40}"
    local desc="$4"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${BIWhite}%s${Color_Off} [" "$desc"
    
    # Filled portion
    printf "${BIGreen}"
    for ((i=0; i<filled; i++)); do printf "${PROGRESS_FULL}"; done
    
    # Empty portion  
    printf "${LGRAY}"
    for ((i=0; i<empty; i++)); do printf "${PROGRESS_EMPTY}"; done
    
    printf "${Color_Off}] ${BIYellow}%3d%%${Color_Off}" "$percentage"
}

# Spinner animation
show_spinner() {
    local pid=$1
    local message="${2:-Working}"
    local delay=0.1
    local spinstr="${SPINNER}"
    
    tput civis # Hide cursor
    
    while kill -0 "$pid" 2>/dev/null; do
        for ((i=0; i<${#spinstr}; i++)); do
            printf "\r${BICyan}%c${Color_Off} %s..." "${spinstr:$i:1}" "$message"
            sleep "$delay"
            if ! kill -0 "$pid" 2>/dev/null; then break 2; fi
        done
    done
    
    printf "\r${ICON_SUCCESS} %s... ${BIGreen}Done${Color_Off}\n" "$message"
    tput cnorm # Show cursor
}

# Status indicator with icon
show_status() {
    local status="$1"
    local description="$2"
    local details="${3:-}"
    
    case "$status" in
        "success"|"ok"|"yes"|"✓")
            printf "  ${ICON_SUCCESS} ${BIWhite}%-22s${Color_Off} ${BIGreen}%s${Color_Off}" "$description" "$details"
            ;;
        "error"|"fail"|"no"|"✗")  
            printf "  ${ICON_ERROR} ${BIWhite}%-22s${Color_Off} ${BIRed}%s${Color_Off}" "$description" "$details"
            ;;
        "warning"|"⚠")
            printf "  ${ICON_WARNING} ${BIWhite}%-22s${Color_Off} ${BIYellow}%s${Color_Off}" "$description" "$details"
            ;;
        "info"|"ℹ")
            printf "  ${ICON_INFO} ${BIWhite}%-22s${Color_Off} ${BICyan}%s${Color_Off}" "$description" "$details"
            ;;
        "working"|"⚙")
            printf "  ${ICON_WORKING} ${BIWhite}%-22s${Color_Off} ${BIYellow}%s${Color_Off}" "$description" "$details"
            ;;
        *)
            printf "  ${BULLET} ${BIWhite}%-22s${Color_Off} %s" "$description" "$details"
            ;;
    esac
}

# Modern header with gradient effect
show_header() {
    local title="$1"
    local subtitle="${2:-}"
    local width
    
    read -r width _ <<< "$(get_terminal_size)"
    width=$((width > 80 ? 80 : width))
    
    echo
    printf "${BICyan}"
    for ((i=0; i<width; i++)); do printf "═"; done
    printf "${Color_Off}\n"
    
    # Center title
    local title_len=${#title}
    local padding=$(( (width - title_len) / 2 ))
    printf "${BIWhite}"
    for ((i=0; i<padding; i++)); do printf " "; done
    printf "%s" "$title"
    printf "${Color_Off}\n"
    
    if [[ -n "$subtitle" ]]; then
        local sub_len=${#subtitle}
        local sub_padding=$(( (width - sub_len) / 2 ))
        printf "${BICyan}"
        for ((i=0; i<sub_padding; i++)); do printf " "; done
        printf "%s" "$subtitle"
        printf "${Color_Off}\n"
    fi
    
    printf "${BICyan}"
    for ((i=0; i<width; i++)); do printf "═"; done
    printf "${Color_Off}\n"
    echo
}

# Clean exit with message
cleanup_exit() {
    tput cnorm # Show cursor
    echo
    printf "${BIGreen}Setup completed successfully!${Color_Off}\n"
    echo
    exit 0
}

# Error exit with message
error_exit() {
    local message="$1"
    tput cnorm # Show cursor
    echo
    printf "${BIRed}Error: %s${Color_Off}\n" "$message"
    echo
    exit 1
}