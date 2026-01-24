# Smart path theme based on maran
# Shows last 3 dirs full, earlier dirs as first letter

# Ensure colors are loaded
autoload -U colors && colors

# Smart path function
_smart_path() {
    local pwd_str="${PWD/#$HOME/~}"
    local -a parts
    parts=("${(@s:/:)pwd_str}")

    local len=${#parts[@]}

    # If 4 or fewer components, show full path
    if (( len <= 4 )); then
        echo "$pwd_str"
        return
    fi

    # Abbreviate all but last 3
    local result=""
    local i
    for (( i=1; i<=len; i++ )); do
        if [[ -z "${parts[i]}" ]]; then
            continue
        elif (( i <= len - 3 )); then
            # Abbreviate to first char
            result+="${parts[i]:0:1}/"
        else
            # Keep full name
            result+="${parts[i]}"
            (( i < len )) && result+="/"
        fi
    done

    # Handle root paths
    [[ "$pwd_str" == /* ]] && [[ "$result" != /* ]] && result="/$result"

    echo "$result"
}

# Update path before each prompt
_smart_path_precmd() {
    _SMART_PATH=$(_smart_path)
}

# Add to precmd hooks
autoload -U add-zsh-hook
add-zsh-hook precmd _smart_path_precmd

# Initialize on load
_SMART_PATH=$(_smart_path)

# Prompt: username@hostname:smart_path git:(branch) $
setopt PROMPT_SUBST
PROMPT='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[yellow]%}%m:%{$fg[green]%}${_SMART_PATH}%{$reset_color%}$(git_prompt_info) %(!.#.$) '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[cyan]%}git:("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
