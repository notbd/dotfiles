# aliases.zsh
#
# Authored by TWZ
# my personal zsh aliases

# shorthands
alias c=clear
alias co=code
alias pn=pnpm
alias s='source ~/.zshrc'
alias zj=zellij

# substitutes
alias cd=z
alias rm=trash
alias cat=bat
alias ccat='\cat'

# eza
alias l='eza --icons=always --color=always --color-scale=all --color-scale-mode=gradient'
alias ls='eza -1 --icons=always --color=always --color-scale=all --color-scale-mode=gradient'
alias la='l -a'
alias ll='ls --long --git'
alias lla='ls -la --git'
alias lt=lst
alias lst='treeify ls'
alias lat='treeify la'
alias llt='treeify ll'
alias llat='treeify lla'

# other utilities
alias trim="awk '{\$1=\$1;print}'"

# FUNCTIONS --------------------------------

take() { mkdir -p "$1" && cd "$1"; } # create a directory and cd into it

treeify() {
  # usage: treeify <command> [<directory>:-.] [<level>:-2]
  # if level specified to 0, the whole tree will be shown
  local cmd="$1" dir="." lvl="2" lvl_arg=""
  [[ -n "$2" ]] && { [[ -d "$2" ]] && { dir="$2"; lvl="${3:-2}"; } || lvl="$2" }
  [[ "$lvl" != "0" ]] && lvl_arg="--level=$lvl"
  eval "$cmd" --tree $lvl_arg "$dir"
}
