export EDITOR="nvim"
bindkey -e  # Use Emacs-style keybindings (no Vim mode in shell)
setopt inc_append_history share_history autopushd
HISTSIZE=5000; SAVEHIST=5000; HISTFILE=~/.zsh_history

# History prefix search - type beginning of command (full line), then use up/down arrows
bindkey '^[[A' history-beginning-search-backward  # Up arrow
bindkey '^[[B' history-beginning-search-forward   # Down arrow

export DOTFILES="$HOME/dotfiles"
export PATH="$DOTFILES/bin:$PATH"

project_session_widget() {
 BUFFER="project-session"
 zle accept-line
}
zle -N project_session_widget
bindkey '^P' project_session_widget   # Option+P (Alt+P)

parse_git_branch() {
    local b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -n $b ]] && echo "%F{red}($b)%f"
}
setopt PROMPT_SUBST
PROMPT=' %~$(parse_git_branch) %# '
