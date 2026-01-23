# shellcheck shell=bash
if [ "$DEBUG" = "true" ]; then echo "$DOTFILESLOC/platforms/mac/iterm2_functions.sh" ; fi

# ==============================================================================
# iTerm2 Shell Functions
# ==============================================================================
# Comprehensive collection of iTerm2 escape code utilities for shell integration.
# Reference: https://iterm2.com/documentation-escape-codes.html
# ==============================================================================

# ------------------------------------------------------------------------------
# INTERNAL HELPER
# ------------------------------------------------------------------------------

# Purpose: Internal helper for sending iTerm2 escape codes (handles tmux passthrough)
# Usage:   _it2_cmd <escape_code>
# Example: _it2_cmd "1337;SetBadgeFormat=$(printf '%s' 'test' | base64)"
_it2_cmd() {
    local code="$1"
    if [ -z "$code" ]; then
        return 1
    fi

    # Check if running inside tmux
    if [ -n "$TMUX" ]; then
        # Wrap in tmux passthrough sequence
        printf '\033Ptmux;\033\033]%s\007\033\\' "$code"
    else
        printf '\033]%s\007' "$code"
    fi
}

# Purpose: Check if we're running in iTerm2
# Usage:   _it2_check
# Returns: 0 if in iTerm2, 1 otherwise
_it2_check() {
    if [ -z "$ITERM_SESSION_ID" ]; then
        printf 'Error: Not running in iTerm2 (ITERM_SESSION_ID not set)\n' >&2
        return 1
    fi
    return 0
}

# ------------------------------------------------------------------------------
# TITLES & NAMES
# ------------------------------------------------------------------------------

# Purpose: Set the current tab title
# Usage:   it2_tab_title <title>
# Example: it2_tab_title "Dev Server"
it2_tab_title() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_tab_title <title>\n'
        printf 'Example: it2_tab_title "Dev Server"\n'
        return 1
    fi
    _it2_check || return 1

    # Tab title uses escape code 0
    printf '\033]0;%s\007' "$*"
}

# Purpose: Set the window title
# Usage:   it2_window_title <title>
# Example: it2_window_title "Production"
it2_window_title() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_window_title <title>\n'
        printf 'Example: it2_window_title "Production"\n'
        return 1
    fi
    _it2_check || return 1

    # Window title uses escape code 2
    printf '\033]2;%s\007' "$*"
}

# Purpose: Set the session name (appears in pane dividers and session list)
# Usage:   it2_session_name <name>
# Example: it2_session_name "backend-api"
it2_session_name() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_session_name <name>\n'
        printf 'Example: it2_session_name "backend-api"\n'
        return 1
    fi
    _it2_check || return 1

    _it2_cmd "1337;SetUserVar=session_name=$(printf '%s' "$*" | base64)"
}

# Purpose: Set both tab and window title at once
# Usage:   it2_title <title>
# Example: it2_title "My Project"
it2_title() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_title <title>\n'
        printf 'Example: it2_title "My Project"\n'
        return 1
    fi
    _it2_check || return 1

    it2_tab_title "$*"
    it2_window_title "$*"
}

# ------------------------------------------------------------------------------
# VISUAL
# ------------------------------------------------------------------------------

# Purpose: Set the tab color using RGB values (0-255 each)
# Usage:   it2_tab_color <r> <g> <b>
# Example: it2_tab_color 255 100 50
it2_tab_color() {
    if [ $# -ne 3 ]; then
        printf 'Usage: it2_tab_color <r> <g> <b>\n'
        printf 'Example: it2_tab_color 255 100 50\n'
        printf 'Values must be 0-255\n'
        return 1
    fi
    _it2_check || return 1

    local r="$1" g="$2" b="$3"

    # Validate range
    if [ "$r" -lt 0 ] || [ "$r" -gt 255 ] || \
       [ "$g" -lt 0 ] || [ "$g" -gt 255 ] || \
       [ "$b" -lt 0 ] || [ "$b" -gt 255 ]; then
        printf 'Error: RGB values must be between 0 and 255\n' >&2
        return 1
    fi

    _it2_cmd "6;1;bg;red;brightness;$r"
    _it2_cmd "6;1;bg;green;brightness;$g"
    _it2_cmd "6;1;bg;blue;brightness;$b"
}

# Purpose: Reset tab color to default
# Usage:   it2_tab_color_reset
# Example: it2_tab_color_reset
it2_tab_color_reset() {
    _it2_check || return 1
    _it2_cmd "6;1;bg;*;default"
}

# Purpose: Set badge watermark text (supports iTerm2 variables like \(user))
# Usage:   it2_badge <text>
# Example: it2_badge "Host: \(hostname)"
it2_badge() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_badge <text>\n'
        printf 'Example: it2_badge "Host: \\(hostname)"\n'
        printf 'Supports iTerm2 variables: \\(user), \\(hostname), \\(path), etc.\n'
        return 1
    fi
    _it2_check || return 1

    local encoded
    encoded=$(printf '%s' "$*" | base64)
    _it2_cmd "1337;SetBadgeFormat=$encoded"
}

# Purpose: Clear the badge watermark
# Usage:   it2_badge_clear
# Example: it2_badge_clear
it2_badge_clear() {
    _it2_check || return 1
    _it2_cmd "1337;SetBadgeFormat="
}

# Purpose: Switch to a named iTerm2 profile
# Usage:   it2_profile <name>
# Example: it2_profile "Solarized Dark"
it2_profile() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_profile <name>\n'
        printf 'Example: it2_profile "Solarized Dark"\n'
        return 1
    fi
    _it2_check || return 1

    _it2_cmd "1337;SetProfile=$*"
}

# Purpose: Set cursor shape
# Usage:   it2_cursor_shape <shape>
# Example: it2_cursor_shape line
it2_cursor_shape() {
    if [ $# -ne 1 ]; then
        printf 'Usage: it2_cursor_shape <shape>\n'
        printf 'Shapes: block, line, underline\n'
        printf 'Example: it2_cursor_shape line\n'
        return 1
    fi
    _it2_check || return 1

    local shape="$1"
    local code

    case "$shape" in
        block)      code=0 ;;
        line)       code=1 ;;
        underline)  code=2 ;;
        *)
            printf 'Error: Invalid shape. Use: block, line, or underline\n' >&2
            return 1
            ;;
    esac

    _it2_cmd "1337;CursorShape=$code"
}

# Purpose: Set cursor color
# Usage:   it2_cursor_color <hex>
# Example: it2_cursor_color "#FF5500"
it2_cursor_color() {
    if [ $# -ne 1 ]; then
        printf 'Usage: it2_cursor_color <hex>\n'
        printf 'Example: it2_cursor_color "#FF5500"\n'
        return 1
    fi
    _it2_check || return 1

    local hex="$1"
    # Remove # prefix if present
    hex="${hex#\#}"

    # Validate hex format
    if ! printf '%s' "$hex" | grep -qE '^[0-9A-Fa-f]{6}$'; then
        printf 'Error: Invalid hex color. Use format: #RRGGBB or RRGGBB\n' >&2
        return 1
    fi

    # Convert to RGB components (iTerm2 expects rgb:RR/GG/BB format)
    local r="${hex:0:2}"
    local g="${hex:2:2}"
    local b="${hex:4:2}"

    printf '\033]Pl%s%s%s\033\\' "$r" "$g" "$b"
}

# Purpose: Set background image (base64 encoded or file path)
# Usage:   it2_background <path>
# Example: it2_background ~/Pictures/wallpaper.png
it2_background() {
    if [ $# -ne 1 ]; then
        printf 'Usage: it2_background <path>\n'
        printf 'Example: it2_background ~/Pictures/wallpaper.png\n'
        return 1
    fi
    _it2_check || return 1

    local filepath="$1"

    # Expand tilde if present
    filepath="${filepath/#\~/$HOME}"

    if [ ! -f "$filepath" ]; then
        printf 'Error: File not found: %s\n' "$filepath" >&2
        return 1
    fi

    local encoded
    encoded=$(base64 < "$filepath")

    _it2_cmd "1337;SetBackgroundImageFile=$encoded"
}

# Purpose: Clear background image
# Usage:   it2_background_clear
# Example: it2_background_clear
it2_background_clear() {
    _it2_check || return 1
    _it2_cmd "1337;SetBackgroundImageFile="
}

# ------------------------------------------------------------------------------
# NOTIFICATIONS
# ------------------------------------------------------------------------------

# Purpose: Post a macOS notification (when terminal not in focus)
# Usage:   it2_notify <message>
# Example: it2_notify "Build completed!"
it2_notify() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_notify <message>\n'
        printf 'Example: it2_notify "Build completed!"\n'
        return 1
    fi
    _it2_check || return 1

    _it2_cmd "9;$*"
}

# Purpose: Request user attention (bounces dock icon if app not focused)
# Usage:   it2_attention
# Example: it2_attention
it2_attention() {
    _it2_check || return 1
    _it2_cmd "1337;RequestAttention=yes"
}

# ------------------------------------------------------------------------------
# ADVANCED
# ------------------------------------------------------------------------------

# Purpose: Set a user-defined variable (accessible in iTerm2 profile scripting)
# Usage:   it2_set_var <key> <value>
# Example: it2_set_var project "my-app"
it2_set_var() {
    if [ $# -ne 2 ]; then
        printf 'Usage: it2_set_var <key> <value>\n'
        printf 'Example: it2_set_var project "my-app"\n'
        return 1
    fi
    _it2_check || return 1

    local key="$1"
    local value="$2"
    local encoded
    encoded=$(printf '%s' "$value" | base64)

    _it2_cmd "1337;SetUserVar=$key=$encoded"
}

# Purpose: Add a mark at the current cursor position (for navigation)
# Usage:   it2_mark
# Example: it2_mark
it2_mark() {
    _it2_check || return 1
    _it2_cmd "1337;SetMark"
}

# Purpose: Add an annotation at the current cursor position
# Usage:   it2_annotate <text>
# Example: it2_annotate "Important output here"
it2_annotate() {
    if [ $# -eq 0 ]; then
        printf 'Usage: it2_annotate <text>\n'
        printf 'Example: it2_annotate "Important output here"\n'
        return 1
    fi
    _it2_check || return 1

    local encoded
    encoded=$(printf '%s' "$*" | base64)
    _it2_cmd "1337;AddAnnotation=$encoded"
}

# Purpose: Copy text to the system clipboard
# Usage:   it2_copy <text>
# Example: it2_copy "some text to copy"
# Example: echo "piped text" | it2_copy
it2_copy() {
    _it2_check || return 1

    local text
    if [ $# -gt 0 ]; then
        text="$*"
    elif [ ! -t 0 ]; then
        # Read from stdin if piped
        text=$(cat)
    else
        printf 'Usage: it2_copy <text>\n'
        printf 'Example: it2_copy "text to copy"\n'
        printf 'Example: echo "piped" | it2_copy\n'
        return 1
    fi

    local encoded
    encoded=$(printf '%s' "$text" | base64)
    _it2_cmd "1337;Copy=:$encoded"
}

# ------------------------------------------------------------------------------
# HELP
# ------------------------------------------------------------------------------

# Purpose: Display all available iTerm2 functions
# Usage:   it2_help
# Example: it2_help
it2_help() {
    cat << 'EOF'
iTerm2 Shell Functions
======================

TITLES & NAMES
  it2_tab_title <title>       Set tab title
  it2_window_title <title>    Set window title
  it2_session_name <name>     Set session name (pane dividers)
  it2_title <title>           Set both tab and window title

VISUAL
  it2_tab_color <r> <g> <b>   Set tab color (RGB 0-255)
  it2_tab_color_reset         Reset tab color to default
  it2_badge <text>            Set badge watermark (supports \(vars))
  it2_badge_clear             Clear badge
  it2_profile <name>          Switch iTerm2 profile
  it2_cursor_shape <shape>    Set cursor: block, line, underline
  it2_cursor_color <hex>      Set cursor color (#RRGGBB)
  it2_background <path>       Set background image
  it2_background_clear        Clear background image

NOTIFICATIONS
  it2_notify <message>        Post macOS notification
  it2_attention               Bounce dock icon

ADVANCED
  it2_set_var <key> <value>   Set user variable
  it2_mark                    Add mark at cursor
  it2_annotate <text>         Add annotation at cursor
  it2_copy <text>             Copy to clipboard

Reference: https://iterm2.com/documentation-escape-codes.html
EOF
}
