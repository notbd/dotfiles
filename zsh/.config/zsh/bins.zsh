# pnpm bin
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# homebrew bin
if [ -x /opt/homebrew/bin/brew ]; then
  # remove duplicates
  # and ensure homebrew paths are at the front
  PATH=${PATH//:\/*homebrew\/bin:/:}; PATH=${PATH#/opt/homebrew/bin:}; PATH=${PATH%:/opt/homebrew/bin}
  PATH=${PATH//:\/*homebrew\/sbin:/:}; PATH=${PATH#/opt/homebrew/sbin:}; PATH=${PATH%:/opt/homebrew/sbin}
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi
