# .zprofile
#
# Login shells, including the non-interactive `zsh -lc` that tools and agents run.
# Interactive shells get the same and more from .zshrc.

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ ! -o interactive ]]; then
  path=("$HOME/.local/bin" $path "$HOME/Library/pnpm/bin")
  (( $+commands[fnm] )) && eval "$(fnm env --shell zsh)"
fi
