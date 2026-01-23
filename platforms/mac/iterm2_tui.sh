#!/bin/zsh
# shellcheck shell=zsh
# shellcheck disable=SC1091   # Don't follow sourced files
# shellcheck disable=SC2034   # Unused variables are color presets
# shellcheck disable=SC2296   # Parameter expansion is valid zsh
# ==============================================================================
# iTerm2 Quick Commands - Simple one-liners (no gum, no menus)
# ==============================================================================
# Fast, minimal TUI functions for iTerm2 customization
# No dependencies, instant execution, built-in help
# ==============================================================================

if [[ "$DEBUG" = "true" ]]; then echo "$DOTFILESLOC/platforms/mac/iterm2_tui.sh"; fi

# Mark as loaded
export _IT2_TUI_LOADED=1

# Ensure base functions are loaded
if [[ -z "$_IT2_LOADED" ]]; then
    source "${DOTFILESLOC:-$HOME/.dotfiles}/platforms/mac/iterm2_functions.sh"
    export _IT2_LOADED=1
fi

# ==============================================================================
# COLOR HELPER
# ==============================================================================

# Purpose: Apply a color preset
# Inputs: preset name (dev, prod, stage, test, local, db, reset)
_tt_color() {
    case "$1" in
        dev)   it2_tab_color 40 80 50 ;;
        prod)  it2_tab_color 90 40 40 ;;
        stage) it2_tab_color 90 75 35 ;;
        test)  it2_tab_color 40 55 90 ;;
        local) it2_tab_color 45 70 80 ;;
        db)    it2_tab_color 70 45 80 ;;
        reset) it2_tab_color_reset ;;
        *)     echo "Unknown preset: $1" && return 1 ;;
    esac
}

# ==============================================================================
# PANEL TITLE & COLOR (20 colors)
# ==============================================================================

# Purpose: Set panel title and color with 20 color presets
# Inputs: [title] [color] - both optional
# Example: ttpanel "API Server" cyan
ttpanel() {
    if [[ $# -eq 0 ]]; then
        cat << 'EOF'
ttpanel - Set panel title and color

Usage:
  ttpanel "Title"              Set title only
  ttpanel COLOR                Set color only
  ttpanel "Title" COLOR        Set both
  ttpanel reset                Reset to default

Colors: red, orange, amber, yellow, lime, green, teal, cyan,
        sky, blue, indigo, purple, violet, magenta, pink,
        rose, coral, brown, slate, gray

Examples:
  ttpanel "API Server" cyan
  ttpanel purple
  ttpanel "DB Connection" green
EOF
        return 0
    fi

    if [[ "$1" == "reset" ]]; then
        it2_tab_color_reset
        it2_tab_title ""
        echo "Panel reset"
        return 0
    fi

    _ttpanel_color() {
        case "$1" in
            red)     it2_tab_color 90 35 35 ;;
            orange)  it2_tab_color 90 55 30 ;;
            amber)   it2_tab_color 90 70 35 ;;
            yellow)  it2_tab_color 85 85 30 ;;
            lime)    it2_tab_color 55 85 35 ;;
            green)   it2_tab_color 35 75 40 ;;
            teal)    it2_tab_color 35 70 65 ;;
            cyan)    it2_tab_color 40 75 85 ;;
            sky)     it2_tab_color 45 65 90 ;;
            blue)    it2_tab_color 40 50 90 ;;
            indigo)  it2_tab_color 50 40 85 ;;
            purple)  it2_tab_color 65 40 85 ;;
            violet)  it2_tab_color 75 45 85 ;;
            magenta) it2_tab_color 85 40 70 ;;
            pink)    it2_tab_color 90 50 65 ;;
            rose)    it2_tab_color 90 45 55 ;;
            coral)   it2_tab_color 90 55 50 ;;
            brown)   it2_tab_color 60 45 35 ;;
            slate)   it2_tab_color 50 55 60 ;;
            gray)    it2_tab_color 55 55 55 ;;
            *)       return 1 ;;
        esac
    }

    if [[ $# -eq 1 ]]; then
        if _ttpanel_color "$1" 2>/dev/null; then
            echo "Color: $1"
        else
            it2_tab_title "$1"
            echo "Title: $1"
        fi
        return 0
    fi

    it2_tab_title "$1"
    if _ttpanel_color "$2" 2>/dev/null; then
        echo "Panel: $1 ($2)"
    else
        echo "Title: $1 (unknown color: $2)"
    fi
}

# ==============================================================================
# TAB TITLE & COLOR
# ==============================================================================

# Purpose: Set tab title and color
# Inputs: [title] [color preset]
# Example: tttab "API Server" prod
tttab() {
    if [[ $# -eq 0 ]]; then
        cat << 'EOF'
tttab - Set tab title and color

Usage:
  tttab "Title"              # Set title only
  tttab dev                  # Set color only (preset)
  tttab "Title" dev          # Set both
  tttab reset                # Reset to default

Presets: dev (green), prod (red), stage (amber), test (blue), local (cyan), db (purple)

Examples:
  tttab "API Server"
  tttab prod
  tttab "Production DB" prod
EOF
        return 0
    fi

    # Handle single arg
    if [[ $# -eq 1 ]]; then
        case "$1" in
            dev|prod|stage|test|local|db)
                _tt_color "$1"
                echo "Tab color: $1"
                ;;
            reset)
                it2_tab_color_reset
                echo "Tab reset"
                ;;
            *)
                it2_tab_title "$1"
                echo "Tab title: $1"
                ;;
        esac
        return 0
    fi

    # Two args: title and color
    it2_tab_title "$1"
    _tt_color "$2"
    echo "Tab: $1 ($2)"
}

# ==============================================================================
# BADGE
# ==============================================================================

# Purpose: Set badge watermark
# Inputs: [text|clear|host|session]
# Example: ttbadge "fixing auth bug"
ttbadge() {
    if [[ $# -eq 0 ]]; then
        cat << 'EOF'
ttbadge - Set badge watermark

Usage:
  ttbadge "text"             # Set badge text
  ttbadge clear              # Clear badge
  ttbadge host               # Show hostname
  ttbadge session            # Show session name

Examples:
  ttbadge "fixing auth bug"
  ttbadge clear
EOF
        return 0
    fi

    case "$1" in
        clear)   it2_badge_clear; echo "Badge cleared" ;;
        host)    it2_badge '\(hostname)'; echo "Badge: hostname" ;;
        session) it2_badge '\(session.name)'; echo "Badge: session" ;;
        *)       it2_badge "$1"; echo "Badge: $1" ;;
    esac
}

# ==============================================================================
# CURSOR
# ==============================================================================

# Purpose: Set cursor style and color
# Inputs: [block|line|underline] [color]
# Example: ttcursor line green
ttcursor() {
    if [[ $# -eq 0 ]]; then
        cat << 'EOF'
ttcursor - Set cursor style

Usage:
  ttcursor block             # Block cursor
  ttcursor line              # Line cursor (vertical bar)
  ttcursor underline         # Underline cursor
  ttcursor [shape] COLOR     # Set color (hex or name)

Colors: white, green, red, blue, amber, purple, cyan, or #RRGGBB

Examples:
  ttcursor line
  ttcursor block green
  ttcursor underline #FF5500
EOF
        return 0
    fi

    case "$1" in
        block|line|underline)
            it2_cursor_shape "$1"
            echo "Cursor: $1"
            [[ -n "$2" ]] && ttcursor "$2"
            ;;
        white)  it2_cursor_color "#FFFFFF"; echo "Cursor color: white" ;;
        green)  it2_cursor_color "#50C878"; echo "Cursor color: green" ;;
        red)    it2_cursor_color "#E74C3C"; echo "Cursor color: red" ;;
        blue)   it2_cursor_color "#5DADE2"; echo "Cursor color: blue" ;;
        amber)  it2_cursor_color "#F4A460"; echo "Cursor color: amber" ;;
        purple) it2_cursor_color "#9B59B6"; echo "Cursor color: purple" ;;
        cyan)   it2_cursor_color "#00CED1"; echo "Cursor color: cyan" ;;
        \#*)    it2_cursor_color "$1"; echo "Cursor color: $1" ;;
        *)      echo "Unknown: $1" && return 1 ;;
    esac
}

# ==============================================================================
# WINDOW & SESSION
# ==============================================================================

# Purpose: Set window and session name
# Inputs: [title|reset]
# Example: ttwindow "Project X"
ttwindow() {
    if [[ $# -eq 0 ]]; then
        cat << 'EOF'
ttwindow - Set window/session name

Usage:
  ttwindow "Title"           # Set both window and session
  ttwindow reset             # Reset to default

Examples:
  ttwindow "Project X"
  ttwindow reset
EOF
        return 0
    fi

    if [[ "$1" == "reset" ]]; then
        it2_window_title ""
        it2_session_name ""
        echo "Window reset"
    else
        it2_window_title "$1"
        it2_session_name "$1"
        echo "Window: $1"
    fi
}

# ==============================================================================
# MARKS & ANNOTATIONS
# ==============================================================================

# Purpose: Add marks and annotations
# Inputs: [note text]
# Example: ttmark "checkpoint"
ttmark() {
    if [[ $# -eq 0 ]]; then
        it2_mark
        echo "Mark added (navigate: Cmd+Shift+↑/↓)"
        return 0
    fi

    if [[ "$1" == "-h" || "$1" == "help" ]]; then
        cat << 'EOF'
ttmark - Add marks and annotations

Usage:
  ttmark                     # Add mark at cursor
  ttmark "note"              # Add annotation with text

Navigate marks: Cmd+Shift+↑ (prev) Cmd+Shift+↓ (next)
EOF
        return 0
    fi

    it2_annotate "$1"
    echo "Annotation: $1"
}

# ==============================================================================
# PROFILE
# ==============================================================================

# Purpose: Switch iTerm2 profile
# Inputs: [profile name]
# Example: ttprofile "Default"
ttprofile() {
    if [[ $# -eq 0 ]]; then
        cat << 'EOF'
ttprofile - Switch iTerm2 profile

Usage:
  ttprofile "Profile Name"   # Switch to profile

Examples:
  ttprofile "Default"
  ttprofile "Presentation"
EOF
        return 0
    fi

    it2_profile "$1"
    echo "Profile: $1"
}

# ==============================================================================
# NOTIFICATION
# ==============================================================================

# Purpose: Send iTerm2 notification
# Inputs: [message]
# Example: ttnotify "Build complete"
ttnotify() {
    local msg="${1:-Done!}"
    it2_notify "$msg"
    echo "Notification sent: $msg"
}

# ==============================================================================
# RESET
# ==============================================================================

# Purpose: Reset all iTerm2 customizations
# Inputs: none
# Example: ttreset
ttreset() {
    it2_tab_color_reset
    it2_badge_clear
    it2_cursor_shape block
    it2_tab_title ""
    it2_window_title ""
    it2_session_name ""
    echo "All iTerm2 customizations reset"
}

# ==============================================================================
# MASTER HELP
# ==============================================================================

# Purpose: Show all available commands
# Inputs: none
# Example: ttt
ttt() {
    cat << 'EOF'
iTerm2 Quick Commands
=====================

tttab [title] [color]    Tab title & color
ttpanel [title] [color]  Panel with 20 colors
ttbadge [text|clear]     Badge watermark
ttcursor [shape] [color] Cursor style
ttwindow [title]         Window & session name
ttmark [note]            Add mark/annotation
ttprofile [name]         Switch profile
ttnotify [msg]           Send notification
ttreset                  Reset all

Color presets: dev, prod, stage, test, local, db
Cursor shapes: block, line, underline

Run any command without args for detailed help.

Examples:
  tttab "API Server"
  tttab prod
  tttab "Production DB" prod
  ttbadge "fixing auth bug"
  ttbadge clear
  ttcursor line
  ttcursor block green
  ttwindow "Project X"
  ttmark "checkpoint"
  ttprofile "Default"
  ttnotify "Build done"
  ttreset
EOF
}
