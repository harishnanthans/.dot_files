export EDITOR="nvim"
set -o vi
setopt inc_append_history share_history autopushd
HISTSIZE=5000; SAVEHIST=5000; HISTFILE=~/.zsh_history

export DOTFILES="$HOME/dotfiles"
export PATH="$DOTFILES/bin:$PATH"

project_session_widget() {
 BUFFER="project-session"
 zle accept-line
}
zle -N project_session_widget
bindkey '^P' project_session_widget   # Option+P (Alt+P)
