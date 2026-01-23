#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2059   # printf format string with variables is intentional for colors
# shellcheck disable=SC1091   # Don't follow sourced files
# shellcheck disable=SC2119   # Functions take optional args from command line
# shellcheck disable=SC2120   # Functions take optional args from command line
# ==============================================================================
# iTerm2 Quick TUI Functions
# ==============================================================================
# Provides tt* quick-access menus for iTerm2 customization.
# Uses fzf when available, falls back to numbered select menus.
# Designed for dark mode with muted, eye-friendly colors.
# ==============================================================================

if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/mac/iterm2_tui.sh"; fi

# Mark as loaded
export _IT2_TUI_LOADED=1

# ------------------------------------------------------------------------------
# DEPENDENCY CHECK
# ------------------------------------------------------------------------------

# Ensure base functions are loaded
if [[ -z "$_IT2_LOADED" ]]; then
    source "${DOTFILESLOC:-$HOME/.dotfiles}/platforms/mac/iterm2_functions.sh"
    export _IT2_LOADED=1
fi

# ------------------------------------------------------------------------------
# COLOR PRESETS (Dark Mode Friendly)
# ------------------------------------------------------------------------------

# Associative array of environment color presets
# Format: "r g b" - RGB values 0-255, muted for eye comfort
declare -A TT_COLORS
TT_COLORS=(
    [dev]="40 80 50"       # Dark green
    [prod]="90 40 40"      # Dark red
    [stage]="90 75 35"     # Dark amber
    [test]="40 55 90"      # Dark blue
    [local]="45 70 80"     # Dark cyan
    [db]="70 45 80"        # Dark purple
)

# Cursor color presets (hex)
declare -A TT_CURSOR_COLORS
TT_CURSOR_COLORS=(
    [white]="FFFFFF"
    [green]="50C878"
    [red]="E74C3C"
    [blue]="5DADE2"
    [amber]="F4A460"
    [purple]="9B59B6"
    [cyan]="00CED1"
)

# ------------------------------------------------------------------------------
# TUI COLORS (muted for dark terminals)
# ------------------------------------------------------------------------------

# Muted colors for TUI elements - easy on the eyes
_TT_DIM='\033[2m'           # Dim text
_TT_RESET='\033[0m'         # Reset
_TT_CYAN='\033[0;36m'       # Muted cyan for borders
_TT_GREEN='\033[0;32m'      # Muted green for success
_TT_YELLOW='\033[0;33m'     # Muted yellow for prompts
_TT_BLUE='\033[0;34m'       # Muted blue for info
_TT_PURPLE='\033[0;35m'     # Muted purple for titles
_TT_GRAY='\033[0;90m'       # Gray for subtle text
_TT_WHITE='\033[0;37m'      # Normal white

# ------------------------------------------------------------------------------
# INTERNAL HELPERS
# ------------------------------------------------------------------------------

# Purpose: Check if fzf is available
# Usage:   _tt_has_fzf && echo "yes"
_tt_has_fzf() {
    command -v fzf &>/dev/null
}

# Purpose: Display a menu using fzf or numbered select
# Usage:   _tt_menu "Title" "option1" "option2" ...
# Returns: Selected option via stdout
_tt_menu() {
    local title="$1"
    shift
    local options=("$@")

    if _tt_has_fzf; then
        # Use fzf with dark theme
        printf '%s\n' "${options[@]}" | fzf \
            --header="$title" \
            --height=~50% \
            --layout=reverse \
            --border=rounded \
            --prompt="› " \
            --pointer="▶" \
            --color="bg+:#2d2d2d,fg+:#ffffff,hl:#5fd7ff,hl+:#5fd7ff,pointer:#00ff87,prompt:#87afff,header:#87afff"
    else
        # Fallback to numbered select
        printf "${_TT_PURPLE}%s${_TT_RESET}\n" "$title"
        printf "${_TT_GRAY}────────────────────${_TT_RESET}\n"

        local i=1
        for opt in "${options[@]}"; do
            printf "${_TT_CYAN}%2d)${_TT_RESET} %s\n" "$i" "$opt"
            ((i++))
        done
        printf "${_TT_GRAY}────────────────────${_TT_RESET}\n"
        printf "${_TT_YELLOW}Select [1-%d]: ${_TT_RESET}" "${#options[@]}"

        local choice
        read -r choice

        # Validate and return selection
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            printf '%s' "${options[$((choice-1))]}"
        fi
    fi
}

# Purpose: Draw a box with title and content lines
# Usage:   _tt_box "Title" "line1" "line2" ...
_tt_box() {
    local title="$1"
    shift
    local lines=("$@")

    # Calculate width based on longest line (min 30)
    local max_len=30
    local title_len=${#title}
    [ "$title_len" -gt "$max_len" ] && max_len=$title_len

    for line in "${lines[@]}"; do
        # Strip ANSI codes for length calculation
        local stripped
        stripped=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local line_len=${#stripped}
        [ "$line_len" -gt "$max_len" ] && max_len=$line_len
    done

    # Add padding
    local width=$((max_len + 2))

    # Top border
    printf "${_TT_CYAN}┌"
    printf '─%.0s' $(seq 1 "$width")
    printf "┐${_TT_RESET}\n"

    # Title
    local title_pad=$(( (width - title_len) / 2 ))
    printf "${_TT_CYAN}│${_TT_RESET}"
    printf "%${title_pad}s" ""
    printf "${_TT_PURPLE}%s${_TT_RESET}" "$title"
    printf "%$(( width - title_pad - title_len ))s" ""
    printf "${_TT_CYAN}│${_TT_RESET}\n"

    # Separator
    printf "${_TT_CYAN}├"
    printf '─%.0s' $(seq 1 "$width")
    printf "┤${_TT_RESET}\n"

    # Content lines
    for line in "${lines[@]}"; do
        local stripped
        stripped=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local line_len=${#stripped}
        printf "${_TT_CYAN}│${_TT_RESET} %s" "$line"
        printf "%$(( width - line_len - 1 ))s" ""
        printf "${_TT_CYAN}│${_TT_RESET}\n"
    done

    # Bottom border
    printf "${_TT_CYAN}└"
    printf '─%.0s' $(seq 1 "$width")
    printf "┘${_TT_RESET}\n"
}

# Purpose: Show a quick status message
# Usage:   _tt_status "success" "Tab color set!"
_tt_status() {
    local type="$1"
    local msg="$2"

    case "$type" in
        success) printf "${_TT_GREEN}✓${_TT_RESET} %s\n" "$msg" ;;
        error)   printf "\033[0;31m✗${_TT_RESET} %s\n" "$msg" ;;
        info)    printf "${_TT_BLUE}ℹ${_TT_RESET} %s\n" "$msg" ;;
        *)       printf "%s\n" "$msg" ;;
    esac
}

# Purpose: Get color preview swatch
# Usage:   _tt_color_swatch "40" "80" "50"
_tt_color_swatch() {
    local r="$1" g="$2" b="$3"
    # Use 256-color approximation for preview
    printf "\033[48;2;%d;%d;%dm  \033[0m" "$r" "$g" "$b"
}

# ------------------------------------------------------------------------------
# TAB FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Tab Setup TUI - set tab title, color, and presets
# Usage:   tttab [preset|title] [preset]
# Example: tttab dev
# Example: tttab "My Title" prod
tttab() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        if [ $# -eq 1 ]; then
            # Single arg - could be preset or title
            local arg="$1"
            if [[ -v TT_COLORS[$arg] ]]; then
                # It's a preset
                local rgb
                read -ra rgb <<< "${TT_COLORS[$arg]}"
                it2_tab_color "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
                _tt_status success "Tab color set to: $arg"
                return 0
            elif [ "$arg" = "reset" ]; then
                it2_tab_color_reset
                _tt_status success "Tab color reset"
                return 0
            else
                # Assume it's a title
                it2_tab_title "$arg"
                _tt_status success "Tab title set: $arg"
                return 0
            fi
        elif [ $# -eq 2 ]; then
            # Two args: title and preset
            it2_tab_title "$1"
            if [[ -v TT_COLORS[$2] ]]; then
                local rgb
                read -ra rgb <<< "${TT_COLORS[$2]}"
                it2_tab_color "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
            fi
            _tt_status success "Tab set: \"$1\" ($2)"
            return 0
        fi
    fi

    # Interactive TUI
    while true; do
        printf "\n"
        _tt_box "Tab Setup" \
            "1) Set Title" \
            "2) Pick Color Preset" \
            "3) Custom RGB" \
            "4) Reset Tab" \
            "${_TT_GRAY}q) Done${_TT_RESET}"

        printf "${_TT_YELLOW}Choice: ${_TT_RESET}"
        read -r choice

        case "$choice" in
            1)
                printf "${_TT_YELLOW}Tab title: ${_TT_RESET}"
                read -r title
                if [ -n "$title" ]; then
                    it2_tab_title "$title"
                    _tt_status success "Tab title set: $title"
                fi
                ;;
            2)
                printf "\n${_TT_PURPLE}Color Presets:${_TT_RESET}\n"
                for preset in dev prod stage test local db; do
                    local rgb
                    read -ra rgb <<< "${TT_COLORS[$preset]}"
                    printf "  $(_tt_color_swatch "${rgb[0]}" "${rgb[1]}" "${rgb[2]}") %s\n" "$preset"
                done
                printf "\n${_TT_YELLOW}Pick preset: ${_TT_RESET}"
                read -r preset
                if [[ -v TT_COLORS[$preset] ]]; then
                    local rgb
                    read -ra rgb <<< "${TT_COLORS[$preset]}"
                    it2_tab_color "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
                    _tt_status success "Tab color set: $preset"
                else
                    _tt_status error "Unknown preset: $preset"
                fi
                ;;
            3)
                printf "${_TT_YELLOW}RGB (e.g., 60 80 100): ${_TT_RESET}"
                read -r r g b
                if [[ "$r" =~ ^[0-9]+$ ]] && [[ "$g" =~ ^[0-9]+$ ]] && [[ "$b" =~ ^[0-9]+$ ]]; then
                    it2_tab_color "$r" "$g" "$b"
                    _tt_status success "Tab color set: $r $g $b"
                else
                    _tt_status error "Invalid RGB values"
                fi
                ;;
            4)
                it2_tab_color_reset
                _tt_status success "Tab color reset to default"
                ;;
            q|Q|"")
                break
                ;;
            *)
                _tt_status error "Invalid choice"
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# BADGE FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Badge Setup TUI - set badge watermark text
# Usage:   ttbadge [text|clear]
# Example: ttbadge "my note"
# Example: ttbadge clear
ttbadge() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        if [ "$1" = "clear" ]; then
            it2_badge_clear
            _tt_status success "Badge cleared"
            return 0
        else
            it2_badge "$*"
            _tt_status success "Badge set: $*"
            return 0
        fi
    fi

    # Interactive TUI
    while true; do
        printf "\n"
        _tt_box "Badge Setup" \
            "1) Set Badge Text" \
            "2) Add Hostname" \
            "3) Add Session Name" \
            "4) Add User Variable" \
            "5) Clear Badge" \
            "${_TT_GRAY}q) Done${_TT_RESET}"

        printf "${_TT_YELLOW}Choice: ${_TT_RESET}"
        read -r choice

        case "$choice" in
            1)
                printf "${_TT_YELLOW}Badge text: ${_TT_RESET}"
                read -r text
                if [ -n "$text" ]; then
                    it2_badge "$text"
                    _tt_status success "Badge set: $text"
                fi
                ;;
            2)
                it2_badge '\(hostname)'
                _tt_status success "Badge set to hostname"
                ;;
            3)
                it2_badge '\(session.name)'
                _tt_status success "Badge set to session name"
                ;;
            4)
                printf "${_TT_YELLOW}Variable name: ${_TT_RESET}"
                read -r varname
                if [ -n "$varname" ]; then
                    it2_badge "\\(user.$varname)"
                    _tt_status success "Badge set to user.$varname"
                fi
                ;;
            5)
                it2_badge_clear
                _tt_status success "Badge cleared"
                ;;
            q|Q|"")
                break
                ;;
            *)
                _tt_status error "Invalid choice"
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# MARKS/ANNOTATIONS FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Marks/Annotations TUI - add navigable marks and notes
# Usage:   ttmark [annotation text]
# Example: ttmark          (adds mark)
# Example: ttmark "note"   (adds annotation)
ttmark() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        it2_annotate "$*"
        _tt_status success "Annotation added: $*"
        return 0
    fi

    # No args = just add a mark
    if [ $# -eq 0 ] && [ ! -t 0 ]; then
        it2_mark
        _tt_status success "Mark added"
        return 0
    fi

    # Interactive TUI
    while true; do
        printf "\n"
        _tt_box "Marks & Annotations" \
            "1) Add Mark Here" \
            "2) Add Annotation" \
            "${_TT_GRAY}─────────────────────────${_TT_RESET}" \
            "${_TT_BLUE}Navigate: Cmd+Shift+Up/Down${_TT_RESET}" \
            "${_TT_GRAY}q) Done${_TT_RESET}"

        printf "${_TT_YELLOW}Choice: ${_TT_RESET}"
        read -r choice

        case "$choice" in
            1)
                it2_mark
                _tt_status success "Mark added at cursor"
                ;;
            2)
                printf "${_TT_YELLOW}Annotation text: ${_TT_RESET}"
                read -r text
                if [ -n "$text" ]; then
                    it2_annotate "$text"
                    _tt_status success "Annotation added: $text"
                fi
                ;;
            q|Q|"")
                break
                ;;
            *)
                _tt_status error "Invalid choice"
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# CURSOR FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Cursor Style TUI - change cursor shape and color
# Usage:   ttcursor [shape] [color]
# Example: ttcursor block
# Example: ttcursor line red
ttcursor() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        local shape="$1"
        local color="${2:-}"

        case "$shape" in
            block|line|underline)
                it2_cursor_shape "$shape"
                _tt_status success "Cursor shape: $shape"
                ;;
            reset)
                it2_cursor_shape block
                _tt_status success "Cursor reset to default"
                return 0
                ;;
            *)
                _tt_status error "Unknown shape: $shape (use block, line, underline)"
                return 1
                ;;
        esac

        if [ -n "$color" ]; then
            if [[ -v TT_CURSOR_COLORS[$color] ]]; then
                it2_cursor_color "#${TT_CURSOR_COLORS[$color]}"
                _tt_status success "Cursor color: $color"
            elif [[ "$color" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                it2_cursor_color "$color"
                _tt_status success "Cursor color: $color"
            fi
        fi
        return 0
    fi

    # Interactive TUI
    while true; do
        printf "\n"
        _tt_box "Cursor Style" \
            "1) Block █" \
            "2) Line │" \
            "3) Underline _" \
            "4) Set Color" \
            "5) Reset to Default" \
            "${_TT_GRAY}q) Done${_TT_RESET}"

        printf "${_TT_YELLOW}Choice: ${_TT_RESET}"
        read -r choice

        case "$choice" in
            1)
                it2_cursor_shape block
                _tt_status success "Cursor shape: block"
                ;;
            2)
                it2_cursor_shape line
                _tt_status success "Cursor shape: line"
                ;;
            3)
                it2_cursor_shape underline
                _tt_status success "Cursor shape: underline"
                ;;
            4)
                printf "\n${_TT_PURPLE}Color Presets:${_TT_RESET} %s\n" "${!TT_CURSOR_COLORS[*]}"
                printf "${_TT_YELLOW}Color (preset or #hex): ${_TT_RESET}"
                read -r color
                if [[ -v TT_CURSOR_COLORS[$color] ]]; then
                    it2_cursor_color "#${TT_CURSOR_COLORS[$color]}"
                    _tt_status success "Cursor color: $color"
                elif [[ "$color" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                    it2_cursor_color "$color"
                    _tt_status success "Cursor color: $color"
                else
                    _tt_status error "Invalid color"
                fi
                ;;
            5)
                it2_cursor_shape block
                _tt_status success "Cursor reset to default"
                ;;
            q|Q|"")
                break
                ;;
            *)
                _tt_status error "Invalid choice"
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# WINDOW/SESSION FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Window/Session TUI - set window and session titles
# Usage:   ttwindow [title]
# Example: ttwindow "My Window"
ttwindow() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        it2_title "$*"
        _tt_status success "Window/Tab title set: $*"
        return 0
    fi

    # Interactive TUI
    while true; do
        printf "\n"
        _tt_box "Window & Session" \
            "1) Set Window Title" \
            "2) Set Session Name" \
            "3) Set Both (Tab + Window)" \
            "4) Reset" \
            "${_TT_GRAY}q) Done${_TT_RESET}"

        printf "${_TT_YELLOW}Choice: ${_TT_RESET}"
        read -r choice

        case "$choice" in
            1)
                printf "${_TT_YELLOW}Window title: ${_TT_RESET}"
                read -r title
                if [ -n "$title" ]; then
                    it2_window_title "$title"
                    _tt_status success "Window title set: $title"
                fi
                ;;
            2)
                printf "${_TT_YELLOW}Session name: ${_TT_RESET}"
                read -r name
                if [ -n "$name" ]; then
                    it2_session_name "$name"
                    _tt_status success "Session name set: $name"
                fi
                ;;
            3)
                printf "${_TT_YELLOW}Title (for both): ${_TT_RESET}"
                read -r title
                if [ -n "$title" ]; then
                    it2_title "$title"
                    _tt_status success "Tab + Window title set: $title"
                fi
                ;;
            4)
                # Reset by setting empty or default
                it2_tab_title ""
                it2_window_title ""
                _tt_status success "Titles reset"
                ;;
            q|Q|"")
                break
                ;;
            *)
                _tt_status error "Invalid choice"
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# PROFILE FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Profile Picker - switch iTerm2 profiles
# Usage:   ttprofile [profile name]
# Example: ttprofile "Default"
ttprofile() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        it2_profile "$*"
        _tt_status success "Profile switched: $*"
        return 0
    fi

    # Interactive mode
    printf "\n"
    _tt_box "Profile Switcher" \
        "${_TT_GRAY}Note: Profiles must exist in iTerm2${_TT_RESET}" \
        "${_TT_GRAY}Common profiles:${_TT_RESET}" \
        "  Default, Hotkey Window" \
        "  Solarized Dark, Solarized Light"

    printf "${_TT_YELLOW}Profile name: ${_TT_RESET}"
    read -r profile
    if [ -n "$profile" ]; then
        it2_profile "$profile"
        _tt_status success "Profile switched: $profile"
    fi
}

# ------------------------------------------------------------------------------
# RESET FUNCTION
# ------------------------------------------------------------------------------

# Purpose: Reset all iTerm2 customizations to defaults
# Usage:   ttreset
ttreset() {
    _it2_check || return 1

    printf "\n"
    _tt_box "Reset All" \
        "This will reset:" \
        "  - Tab color" \
        "  - Badge" \
        "  - Cursor shape" \
        "  - Titles"

    printf "${_TT_YELLOW}Reset all? [y/N]: ${_TT_RESET}"
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        it2_tab_color_reset
        it2_badge_clear
        it2_cursor_shape block
        it2_tab_title ""
        it2_window_title ""

        printf "\n"
        _tt_status success "Tab color reset"
        _tt_status success "Badge cleared"
        _tt_status success "Cursor reset to block"
        _tt_status success "Titles cleared"
        printf "\n${_TT_GREEN}All settings reset to defaults.${_TT_RESET}\n"
    else
        _tt_status info "Reset cancelled"
    fi
}

# ------------------------------------------------------------------------------
# NOTIFICATION FUNCTION
# ------------------------------------------------------------------------------

# Purpose: Send a quick notification
# Usage:   ttnotify [message]
# Example: ttnotify
# Example: ttnotify "Build complete"
# Example: make build; ttnotify "Build finished"
ttnotify() {
    _it2_check || return 1

    local msg="${1:-Done!}"
    it2_notify "$msg"
    _tt_status success "Notification sent: $msg"
}

# ------------------------------------------------------------------------------
# MASTER MENU
# ------------------------------------------------------------------------------

# Purpose: Master TUI menu for all iTerm2 customizations
# Usage:   ttt
ttt() {
    _it2_check || return 1

    if _tt_has_fzf; then
        # fzf-based menu
        while true; do
            local choice
            choice=$(_tt_menu "iTerm2 Quick Setup" \
                "Tab Setup" \
                "Badge Setup" \
                "Marks & Notes" \
                "Cursor Style" \
                "Window & Session" \
                "Switch Profile" \
                "Send Notification" \
                "Reset All" \
                "Quit")

            [ -z "$choice" ] && break

            case "$choice" in
                "Tab Setup")        tttab ;;
                "Badge Setup")      ttbadge ;;
                "Marks & Notes")    ttmark ;;
                "Cursor Style")     ttcursor ;;
                "Window & Session") ttwindow ;;
                "Switch Profile")   ttprofile ;;
                "Send Notification") ttnotify ;;
                "Reset All")        ttreset ;;
                "Quit")             break ;;
            esac
        done
    else
        # Numbered menu fallback
        while true; do
            printf "\n"
            _tt_box "iTerm2 Quick Setup" \
                "1) Tab Setup" \
                "2) Badge Setup" \
                "3) Marks & Notes" \
                "4) Cursor Style" \
                "5) Window & Session" \
                "6) Switch Profile" \
                "7) Send Notification" \
                "8) Reset All" \
                "${_TT_GRAY}q) Quit${_TT_RESET}"

            printf "${_TT_YELLOW}Choice: ${_TT_RESET}"
            read -r choice

            case "$choice" in
                1) tttab ;;
                2) ttbadge ;;
                3) ttmark ;;
                4) ttcursor ;;
                5) ttwindow ;;
                6) ttprofile ;;
                7) ttnotify ;;
                8) ttreset ;;
                q|Q|"") break ;;
                *) _tt_status error "Invalid choice" ;;
            esac
        done
    fi

    printf "\n"
}

# ------------------------------------------------------------------------------
# HELP
# ------------------------------------------------------------------------------

# Purpose: Display all available TUI functions
# Usage:   tthelp
tthelp() {
    cat << 'EOF'
iTerm2 Quick TUI Functions
==========================

QUICK COMMANDS
  ttt                    Master menu (fzf or numbered)
  tttab [preset|title]   Tab color/title setup
  ttbadge [text|clear]   Badge watermark setup
  ttmark [text]          Add marks or annotations
  ttcursor [shape]       Cursor style (block/line/underline)
  ttwindow [title]       Window/session titles
  ttprofile [name]       Switch iTerm2 profile
  ttnotify [msg]         Send notification (default: "Done!")
  ttreset                Reset all to defaults

COLOR PRESETS (for tttab)
  dev     Dark green     prod    Dark red
  stage   Dark amber     test    Dark blue
  local   Dark cyan      db      Dark purple

QUICK EXAMPLES
  tttab dev                  Set tab color to dev (green)
  tttab "API Server" prod    Set title and color
  ttbadge clear              Clear badge
  ttcursor line green        Line cursor, green color
  make build; ttnotify       Notify when done

NAVIGATION
  Marks: Cmd+Shift+Up/Down to navigate

EOF
}
