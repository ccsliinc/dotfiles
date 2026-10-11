# Enhanced Maran Theme with path shortening and Nerd Font icons

# Description: true when the shell's character locale is UTF-8 (Nerd Font icons printable)
# Inputs: none (reads LC_ALL, LC_CTYPE, LANG)
# Outputs: exit status 0 if UTF-8, 1 otherwise
_enhanced_utf8() {
    [[ "${LC_ALL:-${LC_CTYPE:-$LANG}}" == *[Uu][Tt][Ff]8* || "${LC_ALL:-${LC_CTYPE:-$LANG}}" == *[Uu][Tt][Ff]-8* ]]
}

# Function to shorten and iconify path
_enhanced_path() {
    # Nerd Font icons - use \U0 for 5-digit codes, \u for 4-digit.
    # Without a UTF-8 locale zsh errors "character not in range", so fall back to ASCII.
    local icon_home="~" icon_dev="dev" icon_prod="prod" icon_folder=""
    if _enhanced_utf8; then
        icon_home=$(echo -e "\ue617")
        icon_dev=$(echo -e "\U0f0697")
        icon_prod=$(echo -e "\U0f52e")
        icon_folder=$(echo -e "\U0f46a")
    fi

    local dir="$PWD"
    local result=""
    local cols=${COLUMNS:-100}

    # Ultra narrow - just show last component
    if (( cols < 60 )); then
        echo "${dir:t}"
        return
    fi

    # Check if we're under home directory
    if [[ "$dir" == "$HOME"* ]]; then
        local remainder="${dir#$HOME}"

        # Start with home icon
        result="${icon_home}"

        # Check for /Development
        if [[ "$remainder" == "/Development"* ]]; then
            result+=" / ${icon_dev}"
            remainder="${remainder#/Development}"

            # Check for /Production
            if [[ "$remainder" == "/Production"* ]]; then
                result+=" / ${icon_prod}"
                remainder="${remainder#/Production}"
            fi
        fi

        # Append remaining path
        if [[ -n "$remainder" ]]; then
            result+=" ${remainder}"
        fi
    else
        # Not under home - show full path with folder icon
        result="${icon_folder} ${dir}"
    fi

    echo "$result"
}

# Git icon - use \U0 for 5-digit code
_git_icon=""
_enhanced_utf8 && _git_icon=$(echo -e "\U0f062c")

# Git prompt - no space after icon
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[cyan]%}${_git_icon}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"

# Main prompt
PROMPT='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[yellow]%}%m:%{$fg[green]%}$(_enhanced_path)%{$reset_color%}$(git_prompt_info) %(!.#.$) '
