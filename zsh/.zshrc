EDITOR=vim

# aliasing
alias c=clear
alias s='source ~/.zshrc'
alias ls='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always'
alias la='ls -a'
alias ll='ls --long'
alias lla='ls -la'
lst() {level=${1:-2}; ls --tree --level=$level}
lat() {level=${1:-2}; la --tree --level=$level}
llt() {level=${1:-2}; ll --tree --level=$level}
llat() {level=${1:-2}; lla --tree --level=$level}
alias rosetta="arch -x86_64 $@"

# node version manager
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# binaries in pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# oh-my-posh
# if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
#   eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/twz-ohmyposh.toml)"
#   # eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/tokyonight_storm.omp.json)"
# fi

# starship
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

# zinit
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -U compinit && compinit

# Keybindings
WORDCHARS='_' # edit WORDCHARS to enable preferred word stopping behavior
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[[1;9C" end-of-line
bindkey "^[[1;9D" beginning-of-line
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^X\\x7f" backward-kill-line
bindkey "^X^_" redo

# History
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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'

# -------- fzf --------
eval "$(fzf --zsh)"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --level=2 --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# -------- zoxide --------
eval "$(zoxide init zsh)"

# -------- TheFuck --------
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# clear screen
# clear
