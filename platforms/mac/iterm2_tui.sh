#!/bin/zsh
# shellcheck shell=zsh
# shellcheck disable=SC1091   # Don't follow sourced files
# shellcheck disable=SC2034   # Unused variables are color presets
# shellcheck disable=SC2296   # Parameter expansion is valid zsh
# ==============================================================================
# iTerm2 Quick TUI Functions (gum-powered)
# ==============================================================================
# Beautiful terminal UI for iTerm2 customization using charmbracelet/gum.
# Designed for dark mode with bright, high-contrast colors.
# ==============================================================================

if [[ "$DEBUG" = "true" ]]; then echo "$DOTFILESLOC/platforms/mac/iterm2_tui.sh"; fi

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

typeset -A TT_COLORS
TT_COLORS=(
    dev     "40 80 50"
    prod    "90 40 40"
    stage   "90 75 35"
    test    "40 55 90"
    local   "45 70 80"
    db      "70 45 80"
)

# Color descriptions for menu display
typeset -A TT_COLOR_DESC
TT_COLOR_DESC=(
    dev     "dark green"
    prod    "dark red"
    stage   "dark amber"
    test    "dark blue"
    local   "dark cyan"
    db      "dark purple"
)

# Cursor color presets (hex without #)
typeset -A TT_CURSOR_COLORS
TT_CURSOR_COLORS=(
    white   "FFFFFF"
    green   "50C878"
    red     "E74C3C"
    blue    "5DADE2"
    amber   "F4A460"
    purple  "9B59B6"
    cyan    "00CED1"
)

# ------------------------------------------------------------------------------
# GUM STYLE CONSTANTS - BRIGHT FOR DARK TERMINALS
# ------------------------------------------------------------------------------

# Main theme colors (256-color palette) - all bright for visibility
TT_BORDER="51"      # Bright cyan border
TT_CURSOR="207"     # Bright magenta cursor/selection
TT_HEADER="231"     # White headers
TT_MUTED="250"      # Light gray text (visible on dark)
TT_SUCCESS="46"     # Bright green success
TT_ACCENT="213"     # Bright pink accent
TT_TEXT="255"       # Nearly white for main text
TT_DIM="245"        # Medium gray for secondary text

# Debug: uncomment to test colors
# echo "Testing colors:"; gum style --foreground "$TT_BORDER" "cyan"; gum style --foreground "$TT_CURSOR" "magenta"; gum style --foreground "$TT_TEXT" "white"

# ------------------------------------------------------------------------------
# INTERNAL HELPERS
# ------------------------------------------------------------------------------

# Purpose: Display styled header box with icon
# Usage:   _tt_header "Title"
_tt_header() {
    gum style \
        --border rounded \
        --border-foreground "$TT_BORDER" \
        --padding "0 3" \
        --margin "1 0" \
        --foreground "$TT_HEADER" \
        --bold \
        "✦ $1 ✦"
}

# Purpose: Display success message with brief pause
# Usage:   _tt_ok "Message"
_tt_ok() {
    gum style --foreground "$TT_SUCCESS" --bold "✓ $1"
    sleep 0.3
}

# Purpose: Display error message
# Usage:   _tt_err "Message"
_tt_err() {
    gum style --foreground "196" --bold "✗ $1"
}

# Purpose: Display info/muted message
# Usage:   _tt_info "Message"
_tt_info() {
    gum style --foreground "$TT_DIM" "$1"
}

# Purpose: Display a field with label and value
# Usage:   _tt_field "Label" "value" [highlight]
_tt_field() {
    local label="$1"
    local value="${2:-<not set>}"
    local highlight="${3:-0}"
    local arrow=""

    if [[ "$highlight" == "1" ]]; then
        arrow="→ "
    else
        arrow="  "
    fi

    if [[ -z "$2" || "$2" == "" ]]; then
        value="<not set>"
    fi

    printf "%s%-10s │  %s\n" "$(gum style --foreground "$TT_TEXT" "$arrow")" "$(gum style --foreground "$TT_TEXT" "$label")" "$(gum style --foreground "$TT_ACCENT" "$value")"
}

# Purpose: Apply a color preset
# Usage:   _tt_apply_color "dev"
_tt_apply_color() {
    local preset="$1"
    if [[ -z "$preset" || "$preset" == "reset" ]]; then
        it2_tab_color_reset
        return 0
    fi

    local rgb_string="${TT_COLORS[$preset]}"
    if [[ -n "$rgb_string" ]]; then
        local rgb=("${(@s: :)rgb_string}")
        it2_tab_color "${rgb[1]}" "${rgb[2]}" "${rgb[3]}"
    fi
}

# Purpose: Show color picker with swatches
# Usage:   color=$(_tt_color_picker)
_tt_color_picker() {
    local options=(
        "■ dev       dark green"
        "■ prod      dark red"
        "■ stage     dark amber"
        "■ test      dark blue"
        "■ local     dark cyan"
        "■ db        dark purple"
        "○ reset     default"
        "─────────────────────────"
        "  Cancel"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum choose \
        --cursor "→ " \
        --cursor.foreground "$TT_CURSOR" \
        --item.foreground "$TT_TEXT" \
        --selected.foreground "$TT_ACCENT" 2>/dev/null) || return 1

    # Extract preset name (second word after the swatch)
    local preset_name
    preset_name=$(echo "$choice" | awk '{print $2}')

    case "$preset_name" in
        dev|prod|stage|test|local|db|reset)
            echo "$preset_name"
            ;;
        *)
            return 1
            ;;
    esac
}

# Purpose: Graceful exit cleanup
# Usage:   trap '_tt_cleanup' INT
_tt_cleanup() {
    tput cnorm 2>/dev/null  # Restore cursor
    echo
    return 0
}

# ------------------------------------------------------------------------------
# TAB FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Tab Setup TUI - set tab title and color (single-screen form)
# Usage:   tttab [preset|title] [preset]
# Example: tttab dev
# Example: tttab "My Title" prod
tttab() {
    _it2_check || return 1
    trap '_tt_cleanup' INT

    # Quick argument handling
    if [[ $# -gt 0 ]]; then
        if [[ $# -eq 1 ]]; then
            local arg="$1"
            if [[ -n "${TT_COLORS[$arg]}" ]]; then
                _tt_apply_color "$arg"
                _tt_ok "Tab color: $arg"
                return 0
            elif [[ "$arg" == "reset" ]]; then
                it2_tab_color_reset
                _tt_ok "Tab color reset"
                return 0
            else
                it2_tab_title "$arg"
                _tt_ok "Tab title: $arg"
                return 0
            fi
        elif [[ $# -eq 2 ]]; then
            it2_tab_title "$1"
            _tt_apply_color "$2"
            _tt_ok "Tab: \"$1\" ($2)"
            return 0
        fi
    fi

    # Interactive TUI - Single Screen Form
    local title=""
    local color=""

    while true; do
        clear
        _tt_header "Tab Setup"

        echo ""
        _tt_info "  Current settings:"
        echo ""
        echo "  Title    │  $(gum style --foreground "$TT_ACCENT" "${title:-<not set>}")"
        echo "  Color    │  $(gum style --foreground "$TT_ACCENT" "${color:-<not set>}")"
        echo ""

        local choice
        choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
            "Edit title" \
            "Pick color" \
            "───────────────" \
            "Apply & Exit" \
            "Cancel" 2>/dev/null)

        [[ -z "$choice" ]] && break

        case "$choice" in
            "Edit title")
                local new_title
                new_title=$(gum input \
                    --placeholder "Tab title..." \
                    --value "$title" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 40 2>/dev/null)
                if [[ -n "$new_title" ]]; then
                    title="$new_title"
                    it2_tab_title "$title"
                fi
                ;;
            "Pick color")
                local new_color
                new_color=$(_tt_color_picker)
                if [[ -n "$new_color" ]]; then
                    color="$new_color"
                    _tt_apply_color "$color"
                fi
                ;;
            "Apply & Exit"|"Cancel"|"")
                break
                ;;
        esac
    done

    echo ""
    [[ -n "$title" || -n "$color" ]] && _tt_ok "Tab configured"
}

# ------------------------------------------------------------------------------
# BADGE FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Badge Setup TUI - set badge watermark text (single-screen form)
# Usage:   ttbadge [text|clear]
# Example: ttbadge "my note"
# Example: ttbadge clear
ttbadge() {
    _it2_check || return 1
    trap '_tt_cleanup' INT

    # Quick argument handling
    if [[ $# -gt 0 ]]; then
        if [[ "$1" == "clear" ]]; then
            it2_badge_clear
            _tt_ok "Badge cleared"
            return 0
        else
            it2_badge "$*"
            _tt_ok "Badge: $*"
            return 0
        fi
    fi

    # Interactive TUI - Single Screen Form
    local badge=""

    while true; do
        clear
        _tt_header "Badge Setup"

        echo ""
        _tt_info "  Current badge:"
        echo ""
        echo "  Text     │  $(gum style --foreground "$TT_ACCENT" "${badge:-<not set>}")"
        echo ""
        _tt_info "  Variables: \\(hostname) \\(user) \\(session.name)"
        echo ""

        local choice
        choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
            "Set custom text" \
            "Use hostname" \
            "Use session name" \
            "Use username" \
            "Clear badge" \
            "───────────────" \
            "Done" 2>/dev/null)

        [[ -z "$choice" ]] && break

        case "$choice" in
            "Set custom text")
                local text
                text=$(gum input \
                    --placeholder "Badge text..." \
                    --value "$badge" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 40 2>/dev/null)
                if [[ -n "$text" ]]; then
                    badge="$text"
                    it2_badge "$badge"
                    _tt_ok "Badge updated"
                fi
                ;;
            "Use hostname")
                badge='\\(hostname)'
                it2_badge '\(hostname)'
                _tt_ok "Badge: hostname"
                ;;
            "Use session name")
                badge='\\(session.name)'
                it2_badge '\(session.name)'
                _tt_ok "Badge: session name"
                ;;
            "Use username")
                badge='\\(user)'
                it2_badge '\(user)'
                _tt_ok "Badge: username"
                ;;
            "Clear badge")
                badge=""
                it2_badge_clear
                _tt_ok "Badge cleared"
                ;;
            "Done"|"")
                break
                ;;
        esac
    done
    echo ""
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
    trap '_tt_cleanup' INT

    # Quick argument handling
    if [[ $# -gt 0 ]]; then
        it2_annotate "$*"
        _tt_ok "Annotation: $*"
        return 0
    fi

    # Interactive TUI
    clear
    _tt_header "Marks & Annotations"

    echo ""
    _tt_info "  Marks let you navigate output history"
    _tt_info "  Use Cmd+Shift+↑/↓ to jump between marks"
    echo ""

    local choice
    choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
        "Add mark at cursor" \
        "Add annotation..." \
        "───────────────────────" \
        "Done" 2>/dev/null)

    [[ -z "$choice" ]] && { echo ""; return 0; }

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
                --char-limit 0 \
                --width 50 2>/dev/null)
            if [[ -n "$text" ]]; then
                it2_annotate "$text"
                _tt_ok "Annotation: $text"
            fi
            ;;
    esac
    echo ""
}

# ------------------------------------------------------------------------------
# CURSOR FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Cursor Style TUI - change cursor shape and color (single-screen form)
# Usage:   ttcursor [shape] [color]
# Example: ttcursor block
# Example: ttcursor line red
ttcursor() {
    _it2_check || return 1
    trap '_tt_cleanup' INT

    # Quick argument handling
    if [[ $# -gt 0 ]]; then
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

        if [[ -n "$color" ]]; then
            if [[ -n "${TT_CURSOR_COLORS[$color]}" ]]; then
                it2_cursor_color "#${TT_CURSOR_COLORS[$color]}"
                _tt_ok "Color: $color"
            elif [[ "$color" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                it2_cursor_color "$color"
                _tt_ok "Color: $color"
            fi
        fi
        return 0
    fi

    # Interactive TUI - Single Screen Form
    local cur_shape=""
    local cur_color=""

    while true; do
        clear
        _tt_header "Cursor Style"

        echo ""
        _tt_info "  Current settings:"
        echo ""
        echo "  Shape    │  $(gum style --foreground "$TT_ACCENT" "${cur_shape:-<not set>}")"
        echo "  Color    │  $(gum style --foreground "$TT_ACCENT" "${cur_color:-<not set>}")"
        echo ""

        local choice
        choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
            "▌ Block" \
            "│ Line" \
            "_ Underline" \
            "───────────────" \
            "Pick color" \
            "Custom hex..." \
            "───────────────" \
            "Done" 2>/dev/null)

        [[ -z "$choice" ]] && break

        case "$choice" in
            "▌ Block")
                cur_shape="block"
                it2_cursor_shape block
                _tt_ok "Shape: block"
                ;;
            "│ Line")
                cur_shape="line"
                it2_cursor_shape line
                _tt_ok "Shape: line"
                ;;
            "_ Underline")
                cur_shape="underline"
                it2_cursor_shape underline
                _tt_ok "Shape: underline"
                ;;
            "Pick color")
                local color_opts=(
                    "■ white"
                    "■ green"
                    "■ cyan"
                    "■ blue"
                    "■ amber"
                    "■ red"
                    "■ purple"
                    "─────────"
                    "  Cancel"
                )
                local color_pick
                color_pick=$(printf '%s\n' "${color_opts[@]}" | gum choose \
                    --cursor "→ " \
                    --cursor.foreground "$TT_CURSOR" \
                    --item.foreground "$TT_TEXT" \
                    --selected.foreground "$TT_ACCENT" 2>/dev/null)
                local color_name
                color_name=$(echo "$color_pick" | awk '{print $2}')
                if [[ -n "${TT_CURSOR_COLORS[$color_name]}" ]]; then
                    cur_color="$color_name"
                    it2_cursor_color "#${TT_CURSOR_COLORS[$color_name]}"
                    _tt_ok "Color: $color_name"
                fi
                ;;
            "Custom hex...")
                local hex
                hex=$(gum input \
                    --placeholder "#RRGGBB" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 20 2>/dev/null)
                if [[ "$hex" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                    cur_color="$hex"
                    it2_cursor_color "$hex"
                    _tt_ok "Color: $hex"
                fi
                ;;
            "Done"|"")
                break
                ;;
        esac
    done
    echo ""
}

# ------------------------------------------------------------------------------
# WINDOW/SESSION FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Window/Session TUI - set window and session titles (single-screen form)
# Usage:   ttwindow [title]
# Example: ttwindow "My Window"
ttwindow() {
    _it2_check || return 1
    trap '_tt_cleanup' INT

    # Quick argument handling
    if [[ $# -gt 0 ]]; then
        it2_title "$*"
        _tt_ok "Title: $*"
        return 0
    fi

    # Interactive TUI - Single Screen Form
    local window_title=""
    local session_name=""

    while true; do
        clear
        _tt_header "Window & Session"

        echo ""
        _tt_info "  Current settings:"
        echo ""
        echo "  Window   │  $(gum style --foreground "$TT_ACCENT" "${window_title:-<not set>}")"
        echo "  Session  │  $(gum style --foreground "$TT_ACCENT" "${session_name:-<not set>}")"
        echo ""

        local choice
        choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
            "Set window title" \
            "Set session name" \
            "Set both at once" \
            "Reset titles" \
            "───────────────" \
            "Done" 2>/dev/null)

        [[ -z "$choice" ]] && break

        case "$choice" in
            "Set window title")
                local title
                title=$(gum input \
                    --placeholder "Window title..." \
                    --value "$window_title" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 40 2>/dev/null)
                if [[ -n "$title" ]]; then
                    window_title="$title"
                    it2_window_title "$title"
                    _tt_ok "Window title: $title"
                fi
                ;;
            "Set session name")
                local name
                name=$(gum input \
                    --placeholder "Session name..." \
                    --value "$session_name" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 40 2>/dev/null)
                if [[ -n "$name" ]]; then
                    session_name="$name"
                    it2_session_name "$name"
                    _tt_ok "Session: $name"
                fi
                ;;
            "Set both at once")
                local title
                title=$(gum input \
                    --placeholder "Title for both..." \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 40 2>/dev/null)
                if [[ -n "$title" ]]; then
                    window_title="$title"
                    session_name="$title"
                    it2_title "$title"
                    _tt_ok "Title: $title"
                fi
                ;;
            "Reset titles")
                window_title=""
                session_name=""
                it2_tab_title ""
                it2_window_title ""
                _tt_ok "Titles reset"
                ;;
            "Done"|"")
                break
                ;;
        esac
    done
    echo ""
}

# ------------------------------------------------------------------------------
# PROFILE FUNCTIONS
# ------------------------------------------------------------------------------

# Purpose: Profile Picker - switch iTerm2 profiles
# Usage:   ttprofile [profile name]
# Example: ttprofile "Default"
ttprofile() {
    _it2_check || return 1
    trap '_tt_cleanup' INT

    # Quick argument handling
    if [[ $# -gt 0 ]]; then
        it2_profile "$*"
        _tt_ok "Profile: $*"
        return 0
    fi

    # Interactive TUI
    clear
    _tt_header "Profile Switcher"

    echo ""
    _tt_info "  Select a profile or enter a custom name"
    echo ""

    local choice
    choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
        "Default" \
        "Hotkey Window" \
        "Custom..." \
        "───────────────" \
        "Cancel" 2>/dev/null)

    [[ -z "$choice" ]] && { echo ""; return 0; }

    case "$choice" in
        "Custom...")
            local profile
            profile=$(gum input \
                --placeholder "Profile name..." \
                --prompt "› " \
                --prompt.foreground "$TT_BORDER" \
                --cursor.foreground "$TT_CURSOR" \
                --char-limit 0 \
                --width 40 2>/dev/null)
            if [[ -n "$profile" ]]; then
                it2_profile "$profile"
                _tt_ok "Profile: $profile"
            fi
            ;;
        "Cancel"|"─"*|"")
            ;;
        *)
            it2_profile "$choice"
            _tt_ok "Profile: $choice"
            ;;
    esac
    echo ""
}

# ------------------------------------------------------------------------------
# RESET FUNCTION
# ------------------------------------------------------------------------------

# Purpose: Reset all iTerm2 customizations to defaults
# Usage:   ttreset
ttreset() {
    _it2_check || return 1
    trap '_tt_cleanup' INT

    clear
    _tt_header "Reset All"

    echo ""
    _tt_info "  This will reset:"
    echo ""
    gum style --foreground "$TT_DIM" "    • Tab color      → default"
    gum style --foreground "$TT_DIM" "    • Badge          → cleared"
    gum style --foreground "$TT_DIM" "    • Cursor shape   → block"
    gum style --foreground "$TT_DIM" "    • Window title   → cleared"
    gum style --foreground "$TT_DIM" "    • Tab title      → cleared"
    echo ""

    if gum confirm --prompt.foreground "$TT_CURSOR" "Reset all settings?" 2>/dev/null; then
        gum spin --spinner dot --title "Resetting..." -- sleep 0.5
        it2_tab_color_reset
        it2_badge_clear
        it2_cursor_shape block
        it2_tab_title ""
        it2_window_title ""

        echo ""
        _tt_ok "Tab color reset"
        _tt_ok "Badge cleared"
        _tt_ok "Cursor: block"
        _tt_ok "Titles cleared"
        echo ""
        gum style --foreground "$TT_SUCCESS" --bold "✓ All settings reset to defaults."
    else
        echo ""
        _tt_info "Reset cancelled"
    fi
    echo ""
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
    trap '_tt_cleanup' INT

    while true; do
        clear
        _tt_header "iTerm2 Settings"

        echo ""
        _tt_info "  Customize your terminal appearance"
        echo ""

        local choice
        choice=$(gum choose --cursor "→ " --cursor.foreground "$TT_CURSOR" --item.foreground "$TT_TEXT" --selected.foreground "$TT_ACCENT" \
            "Tab Setup       Set title and color" \
            "Badge           Watermark text" \
            "Cursor          Shape and color" \
            "Window/Session  Window and session titles" \
            "Marks           Navigable marks" \
            "Profile         Switch profiles" \
            "Notification    Send alert" \
            "─────────────────────────────────" \
            "Reset All       Clear customizations" \
            "Exit" 2>/dev/null)

        [[ -z "$choice" ]] && break

        # Extract command name (first word)
        local cmd
        cmd=$(echo "$choice" | awk '{print $1}')

        case "$cmd" in
            "Tab")          tttab ;;
            "Badge")        ttbadge ;;
            "Cursor")       ttcursor ;;
            "Window/Session") ttwindow ;;
            "Marks")        ttmark ;;
            "Profile")      ttprofile ;;
            "Notification")
                local msg
                msg=$(gum input \
                    --placeholder "Notification message..." \
                    --value "Done!" \
                    --prompt "› " \
                    --prompt.foreground "$TT_BORDER" \
                    --cursor.foreground "$TT_CURSOR" \
                    --char-limit 0 \
                    --width 40 2>/dev/null)
                if [[ -n "$msg" ]]; then
                    ttnotify "$msg"
                    sleep 0.5
                fi
                ;;
            "Reset")        ttreset ;;
            "Exit"|"─"*|"") break ;;
        esac
    done
    echo ""
}

# ------------------------------------------------------------------------------
# HELP
# ------------------------------------------------------------------------------

# Purpose: Display all available TUI functions
# Usage:   tthelp
tthelp() {
    clear
    gum style \
        --border rounded \
        --border-foreground "$TT_BORDER" \
        --padding "0 3" \
        --margin "1 0" \
        --foreground "$TT_ACCENT" \
        --bold \
        "✦ iTerm2 Quick TUI ✦"

    echo ""
    gum style --foreground "$TT_HEADER" --bold "QUICK COMMANDS"
    echo ""
    gum style --foreground "$TT_DIM" "  ttt                    Master menu"
    gum style --foreground "$TT_DIM" "  tttab [preset|title]   Tab color/title setup"
    gum style --foreground "$TT_DIM" "  ttbadge [text|clear]   Badge watermark"
    gum style --foreground "$TT_DIM" "  ttmark [text]          Marks and annotations"
    gum style --foreground "$TT_DIM" "  ttcursor [shape]       Cursor style (block/line/underline)"
    gum style --foreground "$TT_DIM" "  ttwindow [title]       Window/session titles"
    gum style --foreground "$TT_DIM" "  ttprofile [name]       Switch profile"
    gum style --foreground "$TT_DIM" "  ttnotify [msg]         Send notification"
    gum style --foreground "$TT_DIM" "  ttreset                Reset all to defaults"

    echo ""
    gum style --foreground "$TT_HEADER" --bold "COLOR PRESETS"
    echo ""
    gum style --foreground "$TT_DIM" "  ■ dev     dark green      ■ prod    dark red"
    gum style --foreground "$TT_DIM" "  ■ stage   dark amber      ■ test    dark blue"
    gum style --foreground "$TT_DIM" "  ■ local   dark cyan       ■ db      dark purple"

    echo ""
    gum style --foreground "$TT_HEADER" --bold "EXAMPLES"
    echo ""
    gum style --foreground "$TT_DIM" "  tttab dev                  Set tab to dev green"
    gum style --foreground "$TT_DIM" "  tttab \"API Server\" prod    Title + color"
    gum style --foreground "$TT_DIM" "  ttbadge clear              Clear badge"
    gum style --foreground "$TT_DIM" "  ttcursor line green        Line cursor, green"
    gum style --foreground "$TT_DIM" "  make build; ttnotify       Notify when done"

    echo ""
    gum style --foreground "$TT_DIM" "  Navigate marks: Cmd+Shift+Up/Down"
    echo ""
}
