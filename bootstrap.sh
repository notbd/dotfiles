#!/bin/zsh
#
# bootstrap.sh - apps and dotfiles for a fresh Mac. Safe to re-run; exits non-zero if a step failed.
# Usually started by setup-new-mac.sh; on its own:
#
#   git clone https://github.com/notbd/dotfiles.git ~/.dotfiles && zsh ~/.dotfiles/bootstrap.sh
#
#   1. Homebrew (its installer also installs the Xcode Command Line Tools)
#   2. Brewfile (Brewfile.extra is optional: brew bundle --file=~/.dotfiles/Brewfile.extra)
#   3. link.sh
#   4. Node (fnm) and pnpm global tools
#   5. Python: packages for plain python3 and the venvs, from python/*.txt; then link.sh
#      again for the tools the venvs provide

emulate -R zsh
setopt pipe_fail no_unset

say()  { printf '\n\033[1;36m==== %s ====\033[0m\n' "$*"; }
ok()   { printf '\033[0;32m✓   %s\033[0m\n' "$*"; }
warn() { printf '\033[0;33m!   %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[0;31mx   %s\033[0m\n' "$*" >&2; exit 1; }
fail() { warn "$*"; FAILED+=("$*"); }

DOTFILES="${ZSH_SCRIPT:A:h}"
FAILED=()

say "Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then   # asks for the password itself when run on its own
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || die "Homebrew install failed"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
xcode-select -p >/dev/null 2>&1 || die "Command Line Tools missing: run xcode-select --install, then this again"

say "Brewfile"
export HOMEBREW_BUNDLE_FILE="$DOTFILES/Brewfile" HOMEBREW_BUNDLE_NO_UPGRADE=1   # install what is missing, upgrade nothing
brew bundle check >/dev/null || brew bundle install || fail "brew bundle (re-run: brew bundle --file=$HOMEBREW_BUNDLE_FILE)"

zsh "$DOTFILES/link.sh" || fail "link.sh"

say "Node and pnpm global tools"
eval "$(fnm env --shell zsh)"
{ fnm install 24 && fnm default 24 && fnm install 22 } || fail "fnm install"   # 22: .nvmrc in some projects
eval "$(fnm env --shell zsh)"
export PNPM_HOME="$HOME/Library/pnpm"; path=("$PNPM_HOME/bin" $path)   # pnpm requires its global bin on PATH
# vercel: deploys; @antfu/ni: ni / nr / nlx; mcporter: MCP helper used by agent-reach
# --allow-build: pnpm 10+ otherwise stops to ask which install scripts may run
pnpm add -g --allow-build=esbuild vercel @antfu/ni mcporter </dev/null >/dev/null || fail "pnpm add -g"

say "Python"
# plain python3 is 3.14 (link.sh links it); its packages go to the user site, as on the old Mac
/opt/homebrew/bin/python3.14 -m pip install -q --user --break-system-packages -r "$DOTFILES/python/python3.txt" \
  && ok "python3 packages" || fail "pip install for python3"
venv() {            # $1 venv folder, $2 frozen requirements
  [[ -x $1/bin/python ]] || /opt/homebrew/bin/python3.14 -m venv "$1" || { fail "venv $1"; return }
  "$1/bin/pip" install -q --upgrade pip && "$1/bin/pip" install -q -r "$2" && ok "${1/#$HOME/~}" || fail "pip install for $1"
}
venv ~/.venvs/fivec       "$DOTFILES/python/fivec.txt"
venv ~/.venvs/charts      "$DOTFILES/python/charts.txt"
venv ~/.agent-reach-venv  "$DOTFILES/python/agent-reach.txt"
zsh "$DOTFILES/link.sh" >/dev/null || fail "link.sh (second run, for ~/.local/bin)"

if (( ${#FAILED} )); then
  warn "Steps to look at again:"; printf '      %s\n' "${FAILED[@]}" >&2
  exit 1
fi
ok "bootstrap finished. git commit and ssh need 1Password unlocked with its SSH agent on."
