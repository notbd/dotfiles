# aliases.zsh
#
# Authored by TWZ
# my personal zsh aliases
#
# Rule: never shadow a standard command (ls, cat, cd, cc ...). AI agents and scripts run
# those names and expect the system behaviour. The one exception is rm (see below).
# New tools go by their own names: eza -> l l1 ll la lt lat, zoxide -> z zi, bat.

alias c=clear
alias pn=pnpm
alias s='exec zsh'          # reload: a fresh shell drops removed aliases and functions
alias zj=zellij
alias za='zellij attach'

# rm moves to the Trash. Homebrew's trash takes rm's -r/-f flags; macOS's own /usr/bin/trash
# does not, and Homebrew keeps its copy off PATH, so point at it directly. Real rm: `command rm`.
[[ -x /opt/homebrew/opt/trash/bin/trash ]] && alias rm=/opt/homebrew/opt/trash/bin/trash

# eza
() {
  local e='eza --icons=auto --color-scale=all'
  alias l="$e" l1="$e -1" ll="$e -l --git" la="$e -la --git"
  alias lt="$e --tree --level=2" lat="$e -la --git --tree --level=2"   # deeper: lt -L4 dir
}

take() { mkdir -p "$1" && cd "$1"; }   # create a directory and cd into it
