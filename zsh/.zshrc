# .zshrc
#
# Authored by TWZ
# for my personal zsh setup
#
# H/T:
#   https://github.com/andrew8088/dotfiles/tree/main/zsh
#   https://github.com/josean-dev/dev-environment-files/blob/main/.zshrc

source_if_exists () { [[ -r "$1" ]] && source "$1"; }

source_if_exists ~/.config/zsh/aliases.zsh

precmd() {
  # will run before each prompt, must be cheap or it will slow down prompt
  source_if_exists ~/.config/zsh/aliases.zsh # load aliases
}

# node version manager
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# pnpm bin
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# run homebrew source command again to ensure homebrew bin priority
eval "$(/opt/homebrew/bin/brew shellenv)"

# starship
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

# zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)" # download zinit if not existed
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh" # source and load zinit

# add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# load zsh completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# zsh keybindings
WORDCHARS='_' # edit WORDCHARS to enable preferred word stopping behavior
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[[1;9C" end-of-line
bindkey "^[[1;9D" beginning-of-line
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^X\\x7f" backward-kill-line
bindkey "^X^_" redo

# zsh history
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# zsh completion options
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no

# zsh completion styling
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always --color-scale=all --color-scale-mode=gradient $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --icons=always --color=always --color-scale=all --color-scale-mode=gradient $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat -n --color=always $realpath'

# -------- fzf --------
eval "$(fzf --zsh)"

# fzf preview options
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
export FZF_ALT_C_OPTS="--preview 'eza -a --tree --level=2 --icons=always --color=always --color-scale=all --color-scale-mode=gradient {} | head -200'"

# [[preview options for '**' completion]]
# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd|z)         fzf --preview 'eza -a --tree --level=2 --icons=always --color=always --color-scale=all --color-scale-mode=gradient {} | head -200' "$@" ;;
    export|unset) fzf --preview 'eval "echo $"{}'         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

# fzf find options: use fd instead of the default find command
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
bindkey -r '^[c' # unbind the alt-c keybinding of fzf to avoid conflict with zellij

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; } # listing path candidates
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1";} # listing directory candidates

# fzf-git
FZF_GIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf-git/fzf-git.git"
[ ! -d $FZF_GIT_HOME ] && mkdir -p "$(dirname $FZF_GIT_HOME)" # download fzf-git if not existed
[ ! -d $FZF_GIT_HOME/.git ] && git clone https://github.com/junegunn/fzf-git.sh.git "$FZF_GIT_HOME"
source "${FZF_GIT_HOME}/fzf-git.sh" # source and load script

# -------- zoxide --------
eval "$(zoxide init zsh)"

# -------- TheFuck --------
eval $(thefuck --alias)
eval $(thefuck --alias fk)
