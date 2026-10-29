# .zshrc
#
# Authored by TWZ
# for my personal zsh setup
#
# H/T:
#   https://github.com/andrew8088/dotfiles/tree/main/zsh
#   https://github.com/josean-dev/dev-environment-files/blob/main/.zshrc

# -------- basics --------
typeset -U path fpath          # no duplicates; later prepends move an entry to the front
bindkey -e                     # emacs keys, even when $EDITOR/$VISUAL mention vi
setopt interactive_comments    # `cmd # note` passes no `#` arguments
export EDITOR="zed --wait"

# -------- PATH --------
# .zprofile runs `brew shellenv` for login shells; shells started by apps may lack it
if [[ -d /opt/homebrew ]]; then
  path=(/opt/homebrew/{bin,sbin} $path)
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi
export PNPM_HOME="$HOME/Library/pnpm"
path=("$HOME/.local/bin" $path "$PNPM_HOME/bin")   # pnpm global bins; Homebrew's pnpm itself comes first

# -------- aliases --------
source ~/.config/zsh/aliases.zsh

# -------- plugins and completion (zinit) --------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
[[ -d $ZINIT_HOME/.git ]] || git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
if [[ -r $ZINIT_HOME/zinit.zsh ]]; then      # skipped if the first clone failed (offline)
  typeset -gA ZINIT; ZINIT[NO_ALIASES]=1     # zinit's own `zi` alias would hide zoxide's `zi`
  source "$ZINIT_HOME/zinit.zsh"
  # order matters: completions -> compinit -> fzf-tab -> autosuggestions -> syntax-highlighting
  zinit light zsh-users/zsh-completions
  autoload -Uz compinit && compinit
  zinit light Aloxaf/fzf-tab
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting
else
  autoload -Uz compinit && compinit
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no

# preview a directory listing or a file; anything else (subcommands, options) gets no preview
_preview='f() { if [[ -d $1 ]]; then eza -1a --icons=always --color=always "$1" | head -200; elif [[ -f $1 ]]; then bat -n --color=always "$1"; fi; }; f'
zstyle ':fzf-tab:complete:*:*' fzf-preview "$_preview \$realpath"

# -------- fzf --------
export FZF_DEFAULT_COMMAND="fd --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview '$_preview {}'"
(( $+commands[fzf] )) && FZF_ALT_C_COMMAND= source <(fzf --zsh)   # empty ALT_C_COMMAND: no Alt-C widget
bindkey '^F^F' fzf-file-widget               # Ctrl-F Ctrl-F: file picker (same as Ctrl-T)

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1"; }
_fzf_comprun() {                             # previews for `<cmd> **<Tab>`
  local command=$1; shift
  case "$command" in
    export|unset) fzf --preview 'eval "echo \$"{}' "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview "$_preview {}" "$@" ;;
  esac
}

# -------- fzf-git (Ctrl-G Ctrl-H hashes, Ctrl-G Ctrl-B branches, ...) --------
FZF_GIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/fzf-git/fzf-git.git"
[[ -d $FZF_GIT_HOME/.git ]] || git clone https://github.com/junegunn/fzf-git.sh.git "$FZF_GIT_HOME"
# sourced directly, not through a helper: fzf-git.sh runs as a command when $# == 1
[[ -r $FZF_GIT_HOME/fzf-git.sh ]] && source "$FZF_GIT_HOME/fzf-git.sh"

# -------- key bindings (Ghostty sends these; see .config/ghostty/config) --------
WORDCHARS='_'                       # Option+Left/Right/Backspace stop at / . - ; only _ joins words
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;9D' beginning-of-line # Cmd+Left
bindkey '^[[1;9C' end-of-line       # Cmd+Right
bindkey '^[[1;3D' backward-word     # Option+Left
bindkey '^[[1;3C' forward-word      # Option+Right
bindkey '^U' backward-kill-line     # Cmd+Backspace
bindkey '^X^_' redo                 # Cmd+Shift+Z

# -------- history --------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=$HISTSIZE
setopt share_history hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# -------- tools --------
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"
export SSH_AUTH_SOCK=~/.1password/agent.sock   # 1Password SSH agent (also in ~/.ssh/config)
export HOMEBREW_BUNDLE_FILE=~/.dotfiles/Brewfile   # `brew bundle add <name>` records new installs here
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"   # zoxide asks to be initialised last among tools

# -------- prompt --------
if (( $+commands[starship] )) && [[ $TERM_PROGRAM != Apple_Terminal ]]; then   # Apple Terminal has no Nerd Font
  export STARSHIP_CONFIG=~/.config/starship/starship.toml
  eval "$(starship init zsh)"
fi
