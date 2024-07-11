# pnpm bins
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# source homebrew again (already sourced at login shell) and homebrew bins
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  # remove duplicates,
  # and ensure homebrew paths are at the front
  PATH=$(echo $PATH | sed -E -e 's,(/opt/homebrew/bin|/opt/homebrew/sbin):,,g' -e 's,:(/opt/homebrew/bin|/opt/homebrew/sbin),,g')
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi
