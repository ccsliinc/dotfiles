#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC1091   # Don't follow sourced files
# shellcheck disable=SC2034   # Unused variables are color presets
# shellcheck disable=SC2119   # Functions take optional args from command line
# shellcheck disable=SC2120   # Functions take optional args from command line
# shellcheck disable=SC2317   # exit 1 is reachable when run as script
# ==============================================================================
# iTerm2 Quick TUI Functions (gum-powered)
# ==============================================================================
# Beautiful terminal UI for iTerm2 customization using charmbracelet/gum.
# Designed for dark mode with muted purple/cyan color scheme.
# ==============================================================================

if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/mac/iterm2_tui.sh"; fi

# Mark as loaded
export _IT2_TUI_LOADED=1

# ------------------------------------------------------------------------------
# DEPENDENCY CHECK
# ------------------------------------------------------------------------------

# Check for gum
if ! command -v gum &>/dev/null; then
    echo "gum not installed. Install with: brew install gum"
    return 1 2>/dev/null || exit 1
fi

# Ensure base functions are loaded
if [[ -z "$_IT2_LOADED" ]]; then
    source "${DOTFILESLOC:-$HOME/.dotfiles}/platforms/mac/iterm2_functions.sh"
    export _IT2_LOADED=1
fi

# ------------------------------------------------------------------------------
# COLOR PRESETS (Dark Mode Friendly)
# ------------------------------------------------------------------------------

declare -A TT_COLORS
TT_COLORS=(
    ["dev"]="40 80 50"       # Dark green
    ["prod"]="90 40 40"      # Dark red
    ["stage"]="90 75 35"     # Dark amber
    ["test"]="40 55 90"      # Dark blue
    ["local"]="45 70 80"     # Dark cyan
    ["db"]="70 45 80"        # Dark purple
)

# Color descriptions for menu display
declare -A TT_COLOR_DESC
TT_COLOR_DESC=(
    ["dev"]="dark green"
    ["prod"]="dark red"
    ["stage"]="dark amber"
    ["test"]="dark blue"
    ["local"]="dark cyan"
    ["db"]="dark purple"
)

# Cursor color presets (hex without #)
declare -A TT_CURSOR_COLORS
TT_CURSOR_COLORS=(
    ["white"]="FFFFFF"
    ["green"]="50C878"
    ["red"]="E74C3C"
    ["blue"]="5DADE2"
    ["amber"]="F4A460"
    ["purple"]="9B59B6"
    ["cyan"]="00CED1"
)

# ------------------------------------------------------------------------------
# GUM STYLE CONSTANTS
# ------------------------------------------------------------------------------

# Main theme colors (256-color palette)
TT_BORDER="99"      # Purple border
TT_CURSOR="212"     # Pink cursor/selection
TT_HEADER="39"      # Cyan headers
TT_MUTED="241"      # Muted gray text
TT_SUCCESS="34"     # Green success

# ------------------------------------------------------------------------------
# INTERNAL HELPERS
# ------------------------------------------------------------------------------

# Purpose: Display styled header box
# Usage:   _tt_header "Title"
_tt_header() {
    gum style \
        --border rounded \
        --border-foreground "$TT_BORDER" \
        --padding "0 2" \
        --margin "1 0 0 0" \
        --foreground "$TT_HEADER" \
        "$1"
}

# Purpose: Display success message
# Usage:   _tt_ok "Message"
_tt_ok() {
    gum style --foreground "$TT_SUCCESS" "✓ $1"
}

# Purpose: Display error message
# Usage:   _tt_err "Message"
_tt_err() {
    gum style --foreground "196" "✗ $1"
}

# Purpose: Display info/muted message
# Usage:   _tt_info "Message"
_tt_info() {
    gum style --foreground "$TT_MUTED" "$1"
}

# Purpose: Get color swatch character for menu
# Usage:   _tt_swatch "dev"
_tt_swatch() {
    local preset="$1"
    local rgb desc
    read -ra rgb <<< "${TT_COLORS[$preset]}"
    desc="${TT_COLOR_DESC[$preset]}"
    # Return formatted string for menu
    printf "%-8s ■ %s" "$preset" "$desc"
}

# ------------------------------------------------------------------------------
# TAB FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Tab Setup TUI - set tab title and color
# Usage:   tttab [preset|title] [preset]
# Example: tttab dev
# Example: tttab "My Title" prod
tttab() {
    _it2_check || return 1

    # Quick argument handling
    if [ $# -gt 0 ]; then
        if [ $# -eq 1 ]; then
            local arg="$1"
            if [[ -v TT_COLORS[$arg] ]]; then
                local rgb
                read -ra rgb <<< "${TT_COLORS[$arg]}"
                it2_tab_color "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
                _tt_ok "Tab color: $arg"
                return 0
            elif [ "$arg" = "reset" ]; then
                it2_tab_color_reset
                _tt_ok "Tab color reset"
                return 0
            else
                it2_tab_title "$arg"
                _tt_ok "Tab title: $arg"
                return 0
            fi
        elif [ $# -eq 2 ]; then
            it2_tab_title "$1"
            if [[ -v TT_COLORS[$2] ]]; then
                local rgb
                read -ra rgb <<< "${TT_COLORS[$2]}"
                it2_tab_color "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
            fi
            _tt_ok "Tab: \"$1\" ($2)"
            return 0
        fi
    fi

    # Interactive TUI
    _tt_header "Tab Setup"
    echo

    # Get title
    _tt_info "Enter tab title (or leave empty to skip)"
    local title
    title=$(gum input \
        --placeholder "Tab title..." \
        --prompt "› " \
        --prompt.foreground "$TT_BORDER" \
        --cursor.foreground "$TT_CURSOR" \
        --width 40)

    if [ -n "$title" ]; then
        it2_tab_title "$title"
        _tt_ok "Title set: $title"
        echo
    fi

    # Build color menu
    local options=()
    for preset in dev prod stage test local db; do
        options+=("$(_tt_swatch "$preset")")
    done
    options+=("reset    ○ default")
    options+=("─────────────────────")
    options+=("Done")

    _tt_info "Select tab color"
    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR" \
        --header.foreground "$TT_HEADER")

    # Extract preset name (first word)
    local preset_name
    preset_name=$(echo "$choice" | awk '{print $1}')

    case "$preset_name" in
        dev|prod|stage|test|local|db)
            local rgb
            read -ra rgb <<< "${TT_COLORS[$preset_name]}"
            it2_tab_color "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
            _tt_ok "Color: $preset_name"
            ;;
        reset)
            it2_tab_color_reset
            _tt_ok "Color reset"
            ;;
        Done|─*|"")
            ;;
    esac
    echo
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
            _tt_ok "Badge cleared"
            return 0
        else
            it2_badge "$*"
            _tt_ok "Badge: $*"
            return 0
        fi
    fi

    # Interactive TUI
    _tt_header "Badge Setup"
    echo

    local options=(
        "Set custom text"
        "Show hostname"
        "Show session name"
        "Show username"
        "Clear badge"
        "─────────────────────"
        "Exit"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR")

    case "$choice" in
        "Set custom text")
            local text
            text=$(gum input \
                --placeholder "Badge text..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 40)
            if [ -n "$text" ]; then
                it2_badge "$text"
                _tt_ok "Badge: $text"
            fi
            ;;
        "Show hostname")
            it2_badge '\(hostname)'
            _tt_ok "Badge: hostname"
            ;;
        "Show session name")
            it2_badge '\(session.name)'
            _tt_ok "Badge: session name"
            ;;
        "Show username")
            it2_badge '\(user)'
            _tt_ok "Badge: username"
            ;;
        "Clear badge")
            it2_badge_clear
            _tt_ok "Badge cleared"
            ;;
    esac
    echo
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
        _tt_ok "Annotation: $*"
        return 0
    fi

    # Interactive TUI
    _tt_header "Marks & Annotations"
    echo

    local options=(
        "Add mark at cursor"
        "Add annotation..."
        "─────────────────────"
        "Navigate: Cmd+Shift+↑/↓"
        "Exit"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR")

    case "$choice" in
        "Add mark at cursor")
            it2_mark
            _tt_ok "Mark added"
            ;;
        "Add annotation...")
            local text
            text=$(gum input \
                --placeholder "Annotation text..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 50)
            if [ -n "$text" ]; then
                it2_annotate "$text"
                _tt_ok "Annotation: $text"
            fi
            ;;
    esac
    echo
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
                _tt_ok "Shape: $shape"
                ;;
            reset)
                it2_cursor_shape block
                _tt_ok "Cursor reset"
                return 0
                ;;
            *)
                _tt_err "Unknown shape: $shape (use block, line, underline)"
                return 1
                ;;
        esac

        if [ -n "$color" ]; then
            if [[ -v TT_CURSOR_COLORS[$color] ]]; then
                it2_cursor_color "#${TT_CURSOR_COLORS[$color]}"
                _tt_ok "Color: $color"
            elif [[ "$color" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                it2_cursor_color "$color"
                _tt_ok "Color: $color"
            fi
        fi
        return 0
    fi

    # Interactive TUI
    _tt_header "Cursor Style"
    echo

    # Shape selection
    _tt_info "Select cursor shape"
    local shape_opts=(
        "▌ Block"
        "│ Line"
        "_ Underline"
        "─────────────────"
        "Skip"
    )

    local shape_choice
    shape_choice=$(printf '%s\n' "${shape_opts[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR")

    case "$shape_choice" in
        "▌ Block")
            it2_cursor_shape block
            _tt_ok "Shape: block"
            ;;
        "│ Line")
            it2_cursor_shape line
            _tt_ok "Shape: line"
            ;;
        "_ Underline")
            it2_cursor_shape underline
            _tt_ok "Shape: underline"
            ;;
    esac

    echo
    _tt_info "Select cursor color (or skip)"
    local color_opts=(
        "white"
        "green"
        "cyan"
        "blue"
        "amber"
        "red"
        "purple"
        "Custom hex..."
        "─────────────────"
        "Skip"
    )

    local color_choice
    color_choice=$(printf '%s\n' "${color_opts[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR")

    case "$color_choice" in
        "Custom hex...")
            local hex
            hex=$(gum input \
                --placeholder "#RRGGBB" \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 20)
            if [[ "$hex" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                it2_cursor_color "$hex"
                _tt_ok "Color: $hex"
            fi
            ;;
        Skip|─*|"")
            ;;
        *)
            if [[ -v TT_CURSOR_COLORS[$color_choice] ]]; then
                it2_cursor_color "#${TT_CURSOR_COLORS[$color_choice]}"
                _tt_ok "Color: $color_choice"
            fi
            ;;
    esac
    echo
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
        _tt_ok "Title: $*"
        return 0
    fi

    # Interactive TUI
    _tt_header "Window & Session"
    echo

    local options=(
        "Set window title"
        "Set session name"
        "Set both (tab + window)"
        "Reset titles"
        "─────────────────────"
        "Exit"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR")

    case "$choice" in
        "Set window title")
            local title
            title=$(gum input \
                --placeholder "Window title..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 40)
            if [ -n "$title" ]; then
                it2_window_title "$title"
                _tt_ok "Window title: $title"
            fi
            ;;
        "Set session name")
            local name
            name=$(gum input \
                --placeholder "Session name..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 40)
            if [ -n "$name" ]; then
                it2_session_name "$name"
                _tt_ok "Session: $name"
            fi
            ;;
        "Set both (tab + window)")
            local title
            title=$(gum input \
                --placeholder "Title for both..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 40)
            if [ -n "$title" ]; then
                it2_title "$title"
                _tt_ok "Title: $title"
            fi
            ;;
        "Reset titles")
            it2_tab_title ""
            it2_window_title ""
            _tt_ok "Titles reset"
            ;;
    esac
    echo
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
        _tt_ok "Profile: $*"
        return 0
    fi

    # Interactive TUI
    _tt_header "Profile Switcher"
    echo

    _tt_info "Common profiles (or type custom):"
    local options=(
        "Default"
        "Hotkey Window"
        "Custom..."
        "─────────────────────"
        "Exit"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --selected.foreground "$TT_CURSOR")

    case "$choice" in
        "Custom...")
            local profile
            profile=$(gum input \
                --placeholder "Profile name..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --width 40)
            if [ -n "$profile" ]; then
                it2_profile "$profile"
                _tt_ok "Profile: $profile"
            fi
            ;;
        Exit|─*|"")
            ;;
        *)
            it2_profile "$choice"
            _tt_ok "Profile: $choice"
            ;;
    esac
    echo
}

# ------------------------------------------------------------------------------
# RESET FUNCTION
# ------------------------------------------------------------------------------

# Purpose: Reset all iTerm2 customizations to defaults
# Usage:   ttreset
ttreset() {
    _it2_check || return 1

    _tt_header "Reset All"
    echo

    gum style --foreground "$TT_MUTED" "This will reset:"
    gum style --foreground "$TT_MUTED" "  • Tab color"
    gum style --foreground "$TT_MUTED" "  • Badge"
    gum style --foreground "$TT_MUTED" "  • Cursor shape"
    gum style --foreground "$TT_MUTED" "  • Titles"
    echo

    if gum confirm --prompt.foreground "$TT_CURSOR" "Reset all settings?"; then
        gum spin --spinner dot --title "Resetting..." -- sleep 0.3
        it2_tab_color_reset
        it2_badge_clear
        it2_cursor_shape block
        it2_tab_title ""
        it2_window_title ""

        echo
        _tt_ok "Tab color reset"
        _tt_ok "Badge cleared"
        _tt_ok "Cursor: block"
        _tt_ok "Titles cleared"
        echo
        gum style --foreground "$TT_SUCCESS" --bold "All settings reset to defaults."
    else
        _tt_info "Reset cancelled"
    fi
    echo
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
    _tt_ok "Notification: $msg"
}

# ------------------------------------------------------------------------------
# MASTER MENU
# ------------------------------------------------------------------------------

# Purpose: Master TUI menu for all iTerm2 customizations
# Usage:   ttt
ttt() {
    _it2_check || return 1

    while true; do
        _tt_header "iTerm2 Settings"
        echo

        local options=(
            "Tab Setup"
            "Badge"
            "Cursor"
            "Window/Session"
            "Marks"
            "Profile"
            "Notification"
            "─────────────────────"
            "Reset All"
            "Exit"
        )

        local choice
        choice=$(printf '%s\n' "${options[@]}" | gum choose \
            --cursor "→ " \
            --cursor.foreground "$TT_CURSOR" \
            --selected.foreground "$TT_CURSOR" \
            --header.foreground "$TT_HEADER")

        case "$choice" in
            "Tab Setup")      tttab ;;
            "Badge")          ttbadge ;;
            "Cursor")         ttcursor ;;
            "Window/Session") ttwindow ;;
            "Marks")          ttmark ;;
            "Profile")        ttprofile ;;
            "Notification")
                local msg
                msg=$(gum input \
                    --placeholder "Notification message..." \
                    --value "Done!" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --width 40)
                if [ -n "$msg" ]; then
                    ttnotify "$msg"
                fi
                ;;
            "Reset All")      ttreset ;;
            "Exit"|─*|"")     break ;;
        esac
    done
    echo
}

# ------------------------------------------------------------------------------
# HELP
# ------------------------------------------------------------------------------

# Purpose: Display all available TUI functions
# Usage:   tthelp
tthelp() {
    gum style \
        --border rounded \
        --border-foreground "$TT_BORDER" \
        --padding "1 2" \
        --foreground "$TT_HEADER" \
        "iTerm2 Quick TUI (gum-powered)"

    echo
    gum style --foreground "$TT_HEADER" --bold "QUICK COMMANDS"
    cat << 'EOF'
  ttt                    Master menu
  tttab [preset|title]   Tab color/title setup
  ttbadge [text|clear]   Badge watermark
  ttmark [text]          Marks and annotations
  ttcursor [shape]       Cursor style (block/line/underline)
  ttwindow [title]       Window/session titles
  ttprofile [name]       Switch profile
  ttnotify [msg]         Send notification
  ttreset                Reset all to defaults
EOF

    echo
    gum style --foreground "$TT_HEADER" --bold "COLOR PRESETS"
    cat << 'EOF'
  dev     dark green      prod    dark red
  stage   dark amber      test    dark blue
  local   dark cyan       db      dark purple
EOF

    echo
    gum style --foreground "$TT_HEADER" --bold "EXAMPLES"
    cat << 'EOF'
  tttab dev                  Set tab to dev green
  tttab "API Server" prod    Title + color
  ttbadge clear              Clear badge
  ttcursor line green        Line cursor, green
  make build; ttnotify       Notify when done
EOF

    echo
    gum style --foreground "$TT_MUTED" "Navigate marks: Cmd+Shift+Up/Down"
    echo
}
